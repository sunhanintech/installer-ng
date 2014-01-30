#!/usr/bin/env python
from __future__ import print_function
import os
import sys
import socket
import tempfile
import subprocess
import string
import json
import shutil
from distutils import spawn

CHEF_INSTALL_URL = "https://www.opscode.com/chef/install.sh"
COOKBOOK_PKG_URL = "https://github.com/Scalr/installer-ng/releases/download/v0.2.0/package.tar.gz"


if sys.version_info >= (3, 0, 0):
    raw_input = input


def format_symbol(s):
    """
    Output a consistent format for expected symbols we expect the user to
    input as-is.
    """
    return "`{0}`".format(s)


class InvalidInput(Exception):
    def __init__(self, reason="Unknown error"):
        self.reason = reason


class UserInput(object):
    def __init__(self, prompt_fn, print_fn):
        self.prompt_fn = prompt_fn
        self.print_fn = print_fn

    def prompt(self, q, error_msg, coerce_fn=None):
        if coerce_fn is None:
            coerce_fn = lambda x: x

        while True:
            r = self.prompt_fn(q + "\n> ")
            try:
                ret = coerce_fn(r)
            except InvalidInput as e:
                self.print_fn("{0} ({1})".format(error_msg, e.reason))
            else:
                self.print_fn("")  # Newline
                return ret

    def prompt_select_from_options(self, q, options, error_msg):
        opts_string = ", ".join(map(format_symbol, options))

        def coerce_fn(r):
            if r in options:
                return r
            raise InvalidInput("{0} is not one of {1}".
                    format(format_symbol(r), opts_string))

        return self.prompt("{0} [{1}]".format(q, opts_string), error_msg,
                                              coerce_fn)

    def prompt_yes_no(self, q, error_msg):
        _yes_no_mapping = {"y":True, "n":False}
        ret = self.prompt_select_from_options(q, _yes_no_mapping.keys(),
                                              error_msg)
        return _yes_no_mapping[ret]

    def prompt_ipv4(self, q, error_msg):
        def coerce_fn(r):
            sym = format_symbol(r)

            try:
                socket.inet_aton(r)
            except socket.error:
                raise InvalidInput("{0} is not a valid IP address".format(sym))

            if len(r.split(".")) != 4:
                # Technically speaking, this would be a vlaid IPV4 address,
                # but it's most likely an error.
                raise InvalidInput("Please enter a full address")

            return r

        return self.prompt(q, error_msg, coerce_fn)


class RandomPasswordGenerator(object):
    def __init__(self, random_source):
        self.random_source = random_source
        self._chars = string.letters + string.digits + "$#"  # 64 divides 256

    def make_password(self, length):
        pw_chars = []
        for c in self.random_source(length):
            pw_chars.append(self._chars[ord(c) % len(self._chars)])
        return "".join(pw_chars)


def generate_chef_solo_config(ui, pwgen):
    output = {
        "run_list":  ["recipe[scalr-core::default]"],
    }

    # MySQL configuration
    output["mysql"] = {
        "server_root_password": pwgen.make_password(30),
        "server_debian_password": pwgen.make_password(30),
        "server_repl_password": pwgen.make_password(30),
    }

    # Scalr configuration
    output["scalr"] = {}

    host_ip = ui.prompt_ipv4("Enter the IP (v4) address your instances should"
                             " use to connect to this server",
                             "This is not a valid IP")

    local_ip = ui.prompt_ipv4("Enter the local IP incoming traffic reaches"
                              " this instance through. If you are not using"
                              " NAT or a Cloud Elastic IP, this should be the"
                              " same IP", "This is not a valid IP")

    output["scalr"]["endpoint"] = {
        "host": host_ip,
        "host_ip": host_ip,
        "local_ip": local_ip,
    }

    conn_policy = ui.prompt_select_from_options("To connect to your instances,"
        " should Scalr use the private IP, public IP, or automatically choose"
        " the best one? Use `auto` if you are unsure.",
        ["auto", "public", "local"], "This is not a valid choice")
    output["scalr"]["instances_connection_policy"] = conn_policy

    output["scalr"]["admin"] = {}
    output["scalr"]["admin"]["username"] = "admin"
    output["scalr"]["admin"]["password"] = pwgen.make_password(15)

    output["scalr"]["database"] = {}
    output["scalr"]["database"]["password"] = pwgen.make_password(30)

    return output


class InstallWrapper(object):
    def __init__(self, work_dir, ui, pwgen):
        self.work_dir = work_dir
        self.ui = ui
        self.pwgen = pwgen

        # We only set those up once, but it's not very clean
        self.file_cache_path = os.path.join(work_dir, "cache")
        self.cookbook_path = os.path.join(work_dir, "cookbooks")

        self.solo_json_path = os.path.join(work_dir, "solo.json")
        self.solo_rb_path = os.path.join(work_dir, "solo.rb")

        os.makedirs(self.cookbook_path)  # This should not exist yet

    def _download(self, url):
        name = url.rsplit("/", 1)[1]
        if spawn.find_executable("curl") is not None:
            subprocess.check_call(["curl", "-O", "-L", url])
        elif spawn.find_executable("wget") is not None:
            subprocess.check_call(["wget", "-O", name, url])
        else:
            raise RuntimeError("Neither curl nor wget is available."
                               " Please install one")
        return name

    def create_configuration_files(self):
        print("Outputting configuration")
        solo_json_config = generate_chef_solo_config(self.ui, self.pwgen)
        with open(self.solo_json_path, "w") as f:
            json.dump(solo_json_config, f)

        solo_rb_lines = [
            "file_cache_path '{0}'".format(self.file_cache_path),
            "cookbook_path '{0}'".format(self.cookbook_path),
            "log_level {0}".format(":info"),
            ""
        ]
        with open(self.solo_rb_path, "w") as f:
            f.write("\n".join(solo_rb_lines))

    def install_chef(self):
        print("Installing Chef Solo")
        if spawn.find_executable("chef-solo") is not None:
            # Chef is already installed!
            return

        install = self._download(CHEF_INSTALL_URL)
        subprocess.check_call(["bash", install])

    def download_cookbooks(self):
        print("Downloading Scalr Cookbooks")
        if spawn.find_executable("tar") is None:
            raise RuntimeError("tar is not available. Please install it.")
        pkg = self._download(COOKBOOK_PKG_URL)
        subprocess.check_call(["tar", "xzvf", pkg, "-C", self.cookbook_path])

    def install_scalr(self):
        print("Launching Chef Solo")
        subprocess.check_call(["chef-solo", "-c", self.solo_rb_path, "-j",
                               self.solo_json_path])

    def install(self):
        self.create_configuration_files()
        self.install_chef()
        self.download_cookbooks()
        self.install_scalr()


def main(work_dir, ui, pwgen):
    wrapper = InstallWrapper(work_dir, ui, pwgen)
    wrapper.install()


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script should run as root")
        sys.exit(1)

    current_dir = os.getcwd()
    work_dir = tempfile.mkdtemp()

    try:
        os.chdir(work_dir)
        ui = UserInput(raw_input, print)
        pwgen = RandomPasswordGenerator(os.urandom)
        attributes = main(work_dir, ui, pwgen)
    except KeyboardInterrupt:
        print("Exiting on user interrupt")
    finally:
        os.chdir(current_dir)

    # We don't use this in finally, because we don't want to clean up if we
    # didn't actually finish (to let the user debug).
    # The passwords are worthless if we're not done anyway.
    print("Cleaning up")
    shutil.rmtree(work_dir)
