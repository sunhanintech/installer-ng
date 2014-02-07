#!/usr/bin/env python
from __future__ import print_function
import os
import sys
import socket
import tempfile
import subprocess
import optparse
import string
import json
import shutil
from distutils import spawn


CHEF_INSTALL_URL = "https://www.opscode.com/chef/install.sh"

CHEF_SOLO_BIN = "/opt/chef/bin/chef-solo"
CHEF_RUBY_BIN = "/opt/chef/embedded/bin/ruby"

MINIMUM_CHEF_VERSION = "11.8.0"
MINIMUM_RUBY_VERSION = "1.9.0"

COOKBOOK_VERSION = "1.1.2"
COOKBOOK_PKG_URL = "https://github.com/Scalr/installer-ng/releases/download/v{0}/package.tar.gz".format(COOKBOOK_VERSION)

SCALR_NAME = "scalr"
SCALR_REVISION = "HEAD"
SCALR_REPO = "https://github.com/Scalr/scalr.git"
SCALR_RELEASE = "oss"
SCALR_DEPLOY_TO = "/opt/scalr"

OPENSSL_START_KEY = "-----BEGIN RSA PRIVATE KEY-----"
OPENSSL_END_KEY = "-----END RSA PRIVATE KEY-----"
OPENSSL_PROC_TYPE = "Proc-Type: "
OPENSSL_ENCRYPTED = "ENCRYPTED"

INSTALL_DONE_MSG = """

Congratulations! Scalr has successfully finished installing!

Installer cookbook version: `{cookbook_version}`.


-- Configuration --

Some optional modules have not been installed: DNS, LDAP.


-- Credentials file --

All the credentials that were used are stored in `{solo_json_path}`.

Consider making a backup of those, and deleting this file.


-- MySQL credentials --

Use these credentials to access Scalr's MySQL database.

root : `{root_mysql_password}`
scalr: `{scalr_mysql_password}`


-- Login credentials --

Use these credentials to login to Scalr's web control panel.

Username: `{scalr_admin_username}`
Password: `{scalr_admin_password}`


-- Accessing Scalr --

Scalr is installed at: `{install_path}`

Launch Scalr by browsing to `http://{scalr_host}`

If you can't access Scalr, update your firewall rules and / or security groups.

If you need help, check out Scalr's online documentation: `http://wiki.scalr.com`


-- Quickstart Roles --

Scalr provides, free of charge, up-to-date role images for AWS. Those will help you get started with Scalr.

To get access, you will need to provide the Scalr team with your Scalr installation ID.
Your Scalr installation ID is located in this file: `{scalr_id_file}`
We've read the file for you, its contents are:      `{scalr_id}`

Please submit those contents to this form `http://goo.gl/qD4mpa`

Once done, please run this command `php {sync_shared_roles_script}`

"""


if sys.version_info >= (3, 0, 0):
    raw_input = input


def check_output(*popenargs, **kwargs):
    # Python 2.6 support
    if "stdout" in kwargs:
        raise ValueError("stdout argument not allowed, it will be overridden.")
    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        raise subprocess.CalledProcessError(retcode, cmd, output=output)
    return output


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

    def prompt_ssh_key(self, q, error_msg):
        key = ""

        while not key:
            first_line = self.prompt_fn(q + ">\n")
            if first_line != OPENSSL_START_KEY:
                self.print_fn("{0} (This is not an SSH private key)"
                              .format(error_msg))
                continue

            lines = [first_line]
            while 1:
                line = self.prompt_fn("")
                lines.append(line)

                if line == OPENSSL_END_KEY:
                    lines.append("")  # Newline
                    key = "\n".join(lines)
                    break

                if (line.startswith(OPENSSL_PROC_TYPE) and
                    OPENSSL_ENCRYPTED in line):
                    self.print_fn("{0} (This is an encrypted key"
                                  .format(error_msg))
                    break

        return key

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
        self._chars = string.letters + string.digits + "+="  # 64 divides 256

    def make_password(self, length):
        pw_chars = []
        for c in self.random_source(length):
            pw_chars.append(self._chars[ord(c) % len(self._chars)])
        return "".join(pw_chars)


def generate_chef_solo_config(options, ui, pwgen):
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
                             " use to connect to this server. ",
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

    if not options.advanced:
        revision = SCALR_REVISION
        repo = SCALR_REPO
        release = SCALR_RELEASE
        ssh_key = ""
        ssh_key_path = ""
    else:
        revision = ui.prompt("Enter the revision to deploy (e.g. HEAD)", "")
        repo = ui.prompt("Enter the repository to clone", "")
        release = ui.prompt_select_from_options("What Scalr release is this?",
            ["oss", "ee"], "This is not a valid choice")
        ssh_key = ui.prompt_ssh_key("Enter (paste) the SSH private key to use",
                                    "Invalid key. Please try again.")
        ssh_key_path = os.path.join(os.path.expanduser("~"), "scalr-deploy.pem")

    output["scalr"]["package"] = {
        "revision": revision,
        "repo": repo,
        "release": release,
        "name": SCALR_NAME,
        "deploy_to": SCALR_DEPLOY_TO,
    }

    output["scalr"]["deployment"] = {
        "ssh_key": ssh_key,
        "ssh_key_path": ssh_key_path,
    }

    return output


class InstallWrapper(object):
    def __init__(self, work_dir, options, ui, pwgen):
        self.work_dir = work_dir
        self.options = options
        self.ui = ui
        self.pwgen = pwgen

        # We only set those up once, but it's not very clean
        self.file_cache_path = os.path.join(work_dir, "cache")
        self.cookbook_path = os.path.join(work_dir, "cookbooks")

        self.solo_rb_path = os.path.join(work_dir, "solo.rb")

        # We don't change that file across runs.
        self.solo_json_path = os.path.join(os.path.expanduser("~"), "solo.json")

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

    def generate_config(self):
        self.solo_json_config = generate_chef_solo_config(self.options, self.ui, self.pwgen)

    def load_config(self):
        with open(self.solo_json_path) as f:
            self.solo_json_config = json.load(f)

    def create_configuration_files(self):
        print("Outputting configuration")

        if os.path.exists(self.solo_json_path):
            self.load_config()
            print("JSON Configuration already exists. Using it.")
        else:
            self.generate_config()
            with open(self.solo_json_path, "w") as f:
                json.dump(self.solo_json_config, f)

        solo_rb_lines = [
            "file_cache_path '{0}'".format(self.file_cache_path),
            "cookbook_path '{0}'".format(self.cookbook_path),
            "log_level {0}".format(":info"),
            ""
        ]
        with open(self.solo_rb_path, "w") as f:
            f.write("\n".join(solo_rb_lines))

    def _has_compliant_chef(self):
        # Check for Chef version and ruby version
        try:
            chef_version = check_output([CHEF_SOLO_BIN, "-v"])
            _, ver = chef_version.split(" ")
            if ver < MINIMUM_CHEF_VERSION:
                return False

            ruby_version = check_output([CHEF_RUBY_BIN, "-v"])
            _, ver, _ = ruby_version.split(" ", 2)
            if ver < MINIMUM_RUBY_VERSION:
                return False

        except (ValueError, OSError, subprocess.CalledProcessError):
            # ValueError: we didn't recognize the version string
            # OSError: it's not installed
            # CalledProcessError: something crashed
            return False

        else:
            return True

    def install_chef(self):
        if self._has_compliant_chef():
            # Chef is already installed!
            return

        print("Installing Chef Solo")
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
        subprocess.check_call([CHEF_SOLO_BIN, "-c", self.solo_rb_path, "-j",
                               self.solo_json_path])

    def finish(self):
        install_path = os.path.join(self.solo_json_config["scalr"]["package"]["deploy_to"], "current")

        id_file_path = os.path.join(install_path, "app", "etc", "id")
        with open(id_file_path) as f:
            scalr_id = f.read().strip()

        sync_shared_roles_script = os.path.join(install_path, "app", "tools",
                                                 "sync_shared_roles.php")

        print(INSTALL_DONE_MSG.format(
            install_path=install_path,
            scalr_host=self.solo_json_config["scalr"]["endpoint"]["host"],
            root_mysql_password=self.solo_json_config["mysql"]["server_root_password"],
            scalr_mysql_password=self.solo_json_config["scalr"]["database"]["password"],
            scalr_admin_username=self.solo_json_config["scalr"]["admin"]["username"],
            scalr_admin_password=self.solo_json_config["scalr"]["admin"]["password"],
            scalr_id_file=id_file_path,
            scalr_id=scalr_id,
            sync_shared_roles_script=sync_shared_roles_script,
            solo_json_path=self.solo_json_path,
            cookbook_version=COOKBOOK_VERSION
        ))


    def install(self):
        self.create_configuration_files()
        self.install_chef()
        self.download_cookbooks()
        self.install_scalr()
        self.finish()


def main(work_dir, options, ui, pwgen):
    wrapper = InstallWrapper(work_dir, options, ui, pwgen)
    wrapper.install()


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script should run as root")
        sys.exit(1)

    parser = optparse.OptionParser()
    parser.add_option("-a", "--advanced", action='store_true', default=False,
                      help="Advanced configuration options")
    options, args = parser.parse_args()

    current_dir = os.getcwd()
    work_dir = tempfile.mkdtemp()

    try:
        os.chdir(work_dir)
        ui = UserInput(raw_input, print)
        pwgen = RandomPasswordGenerator(os.urandom)
        attributes = main(work_dir, options, ui, pwgen)
    except KeyboardInterrupt:
        print("Exiting on user interrupt")
    finally:
        if options.advanced:
            print("WARNING: Your SSH key may be stored on this server")
            print("Please check the attributes file, and SSH key file")

        os.chdir(current_dir)
