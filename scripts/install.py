#!/usr/bin/env python
from __future__ import print_function

import os
import sys
import select
import traceback
import socket
import tempfile
import subprocess
import urllib
import urllib2
import re
import optparse
import string
import json
import shutil
import contextlib

from distutils import spawn


ISSUES_URL = "https://github.com/scalr/installer-ng/issues"

CHEF_INSTALL_URL = "https://www.opscode.com/chef/install.sh"

CHEF_SOLO_BIN = "/opt/chef/bin/chef-solo"
CHEF_RUBY_BIN = "/opt/chef/embedded/bin/ruby"

MINIMUM_CHEF_VERSION = "11.0.0"
MINIMUM_RUBY_VERSION = "1.9.0"

DEFAULT_COOKBOOK_VERSION = "3.2.0"
COOKBOOK_PKG_URL_FORMAT = "https://s3.amazonaws.com/installer.scalr.com/releases/installer-ng-v{0}.tar.gz"

INSTALLER_UMASK = 0o22
OUT_LOG = "scalr.install.out.log"
ERR_LOG = "scalr.install.err.log"

# Supported versions
SCALR_VERSION_4_5 = "4.5"
SCALR_VERSION_5_0 = "5.0"
SUPPORTED_VERSIONS = [SCALR_VERSION_4_5, SCALR_VERSION_5_0]

# Deploy parmeters
SCALR_NAME = "scalr"
SCALR_DEPLOY_TO = "/opt/scalr"

# Defaults
DEFAULT_SCALR_REPO = "git://github.com/Scalr/scalr.git"
DEFAULT_SCALR_GIT_REV = SCALR_VERSION_4_5
DEFAULT_SCALR_VERSION = SCALR_VERSION_4_5


# Notification configuration
EMAIL_RE = re.compile(r"[^@]+@[^@]+\.[^@]+")

NOTIFICATION_ATTR_EMAIL = "email"
NOTIFICATION_ATTR_ID = "scalr_installation_id"
NOTIFICATION_FORM_URL = " https://forms.hubspot.com/uploads/form/v2/342633/6bd4c87d-cd6b-4541-b8bb-043d65a5555a"
NOTIFICATION_FORM_STATUS_SUCCESS = 204

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


-- Accessing Scalr --

Scalr is installed at: `{install_path}`

Launch Scalr by browsing to `http://{scalr_host}`

If you can't access Scalr, update your firewall rules and / or security groups.

If you need help, check out Scalr's online documentation: `http://wiki.scalr.com`


-- Login credentials --

Use these credentials to login to Scalr's web control panel.

Username: `{scalr_admin_username}`
Password: `{scalr_admin_password}`


-- Quickstart Roles --

Scalr provides, free of charge, up-to-date role images for AWS. Those will help you get started with Scalr.

To get access, you will need to provide the Scalr team with your Scalr installation ID.
Your Scalr installation ID is located in this file: `{scalr_id_file}`
We've read the file for you, its contents are:      `{scalr_id}`

Please submit those contents to this form `http://hub.am/1fDAc2B`

Once done, please run this command `php {sync_shared_roles_script}`

"""


if sys.version_info >= (3, 0, 0):
    raw_input = input


@contextlib.contextmanager
def umask(mask):
    old_mask = os.umask(mask)
    yield
    os.umask(old_mask)


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


class InstallerFailure(Exception):
    pass


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

    def prompt_email(self, q, error_msg):
        def coerce_fn(r):
            if not EMAIL_RE.match(r):
                raise InvalidInput("{0} is not a valid email "
                                   "address".format(format_symbol(r)))
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
        "run_list":  ["recipe[apt::default]", "recipe[scalr-core::default]"],
    }

    # What are we installing?

    if not options.advanced:
        revision = DEFAULT_SCALR_GIT_REV
        repo = DEFAULT_SCALR_REPO
        version = DEFAULT_SCALR_VERSION
        ssh_key = ""
        ssh_key_path = ""
    else:
        revision = ui.prompt("Enter the revision to deploy (e.g. HEAD)", "")
        repo = ui.prompt("Enter the repository to clone", "")
        version = ui.prompt_select_from_options("What Scalr version is this?",
            SUPPORTED_VERSIONS, "This is not a valid choice")
        ssh_key = ui.prompt_ssh_key("Enter (paste) the SSH private key to use",
                                    "Invalid key. Please try again.")
        ssh_key_path = os.path.join(os.path.expanduser("~"), "scalr-deploy.pem")

    # MySQL configuration
    output["mysql"] = {}

    mysql_passwords = ["server_root_password", "server_debian_password",
                       "server_repl_password"]

    for mysql_password in mysql_passwords:
        if options.passwords:
            pw = ui.prompt("Enter password for: {0}".format(mysql_password),
                           "")
        else:
            pw = pwgen.make_password(30)
        output["mysql"][mysql_password] = pw

    # Scalr configuration
    output["scalr"] = {}

    host_ip = ui.prompt_ipv4("Enter the IP (v4) address your instances should"
                             " use to connect to this server. ",
                             "This is not a valid IP")

    if version == SCALR_VERSION_4_5:
        local_ip = ui.prompt_ipv4("Enter the local IP incoming traffic reaches"
                                  " this instance through. If you are not"
                                  " using NAT or a Cloud Elastic IP, this"
                                  " should be the same IP",
                                  "This is not a valid IP")
    else:
        local_ip = ""

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

    output["scalr"]["package"] = {
        "revision": revision,
        "repo": repo,
        "version": version,
        "name": SCALR_NAME,
        "deploy_to": SCALR_DEPLOY_TO,
    }

    output["scalr"]["deployment"] = {
        "ssh_key": ssh_key,
        "ssh_key_path": ssh_key_path,
    }

    output["apt"] = {
        "compile_time_update": True
    }

    # System parameters
    ## Disable apparmor in the ntp cookbook if it's not installed
    if spawn.find_executable("aa-status") is None:
        output['ntp'] = {'apparmor_enabled': False}

    return output


class InstallWrapper(object):
    def __init__(self, work_dir, options, ui, pwgen, out_file, err_file):
        self.work_dir = work_dir
        self.options = options
        self.ui = ui
        self.pwgen = pwgen

        self._out_file = out_file
        self._err_file = err_file

        # We only set those up once, but it's not very clean
        self.file_cache_path = os.path.join(work_dir, "cache")
        self.cookbook_path = os.path.join(work_dir, "cookbooks")
        self.solo_rb_path = os.path.join(work_dir, "solo.rb")

        # We don't change that file across runs.
        self.solo_json_path = os.path.join(os.path.expanduser("~"), "solo.json")

        os.makedirs(self.cookbook_path)  # This should not exist yet

    def _multiplex_write(self, s, files, nl):
        for f in files:
            f.write(s)
            if nl:
                f.write('\n')

    def write_out(self, s, nl=False):
        self._multiplex_write(s, [self._out_file, sys.stdout], nl)

    def write_err(self, s, nl=False):
        self._multiplex_write(s, [self._err_file, sys.stderr], nl)

    def _download(self, url):
        name = url.rsplit("/", 1)[1]
        if spawn.find_executable("curl") is not None:
            subprocess.check_call(["curl", "--fail", "-O", "-L", url])
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
        self.write_out("Creating configuration", nl=True)

        if os.path.exists(self.solo_json_path):
            self.load_config()
            self.write_out("JSON Configuration already exists. Using it.", nl=True)
        else:
            self.generate_config()
            with open(self.solo_json_path, "w") as f:
                json.dump(self.solo_json_config, f, indent=2, separators=(',', ': '))

        solo_rb_lines = [
            "file_cache_path '{0}'".format(self.file_cache_path),
            "cookbook_path '{0}'".format(self.cookbook_path),
            ""
        ]
        with open(self.solo_rb_path, "w") as f:
            f.write("\n".join(solo_rb_lines))

    def prompt_for_notifications(self):
        self.user_email = None

        if self.options.noprompt:
            return

        signup = ui.prompt_yes_no("Would you like to be notified of "
                                  "Scalr security updates and critical bug "
                                  "fixes? Notifications are delivered by "
                                  "email.", "This isn't a valid choice")
        if signup:
            email = ui.prompt_email("Please enter your email address",
                                    "This is not a valid email")
            self.user_email = email

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

        self.write_out("Installing Chef Solo", nl=True)
        install = self._download(CHEF_INSTALL_URL)
        subprocess.check_call(["bash", install])

    def download_cookbooks(self):
        url = COOKBOOK_PKG_URL_FORMAT.format(self.options.release)
        self.write_out("Downloading Scalr Cookbooks: {0}".format(url), nl=True)
        if spawn.find_executable("tar") is None:
            raise RuntimeError("tar is not available. Please install it.")
        pkg = self._download(url)
        subprocess.check_call(["tar", "xzvf", pkg, "-C", self.cookbook_path])

    def install_scalr(self):
        self.write_out("Launching Chef Solo", nl=True)
        log_level = "debug" if self.options.verbose else "info"

        args = [CHEF_SOLO_BIN,
                "--config", self.solo_rb_path,
                "--json-attributes", self.solo_json_path,
                "--log_level", log_level]

        p = subprocess.Popen(args, bufsize=1, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        fd_mapping = {
            p.stdout.fileno(): (p.stdout, self.write_out),
            p.stderr.fileno(): (p.stderr, self.write_err)
        }

        while True:
            for_read, _, _ = select.select(fd_mapping.keys(), [], [])
            for fd in for_read:
                # By construction, fd is in fd_mapping
                stream, handler = fd_mapping[fd]
                handler(stream.readline())
            if p.poll() is not None:
                break

        retcode = p.wait()  # This doesn't block, we have exited already
        if retcode != 0:
            raise InstallerFailure("The installer failed")


    def finish(self):
        # Multiple paths
        install_path = os.path.join(self.solo_json_config["scalr"]["package"]["deploy_to"], "current")

        id_file_path = os.path.join(install_path, "app", "etc", "id")
        with open(id_file_path) as f:
            scalr_id = f.read().strip()

        sync_shared_roles_script = os.path.join(install_path, "app", "tools",
                                                 "sync_shared_roles.php")
        # Subscribe to security notifications
        if self.user_email is not None:
            # The user wants security and critical updates notifications
            # Submit the user's email for notifications
            # Submit the Scalr installation ID for deduplication
            data = urllib.urlencode({
                NOTIFICATION_ATTR_EMAIL: self.user_email,
                NOTIFICATION_ATTR_ID: scalr_id})

            error_message = "WARNING! Failed to subscribe to notifications"

            try:
                res = urllib2.urlopen(NOTIFICATION_FORM_URL, data)
            except urllib2.URLError as e:
                self.write_out(error_message, nl=True)
                self.write_out(e.reason, nl=True)
            else:
                if res.getcode() != NOTIFICATION_FORM_STATUS_SUCCESS:
                    self.write_out(error_message, nl=True)
                else:
                    self.write_out("Successfully signed up for notifications", nl=True)

        # Output message
        self.write_out(INSTALL_DONE_MSG.format(
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
            cookbook_version=self.options.release
        ), nl=True)


    def install(self):
        self.create_configuration_files()
        self.prompt_for_notifications()
        self.install_chef()
        self.download_cookbooks()
        self.install_scalr()
        self.finish()


def main(work_dir, options, ui, pwgen, out_file, err_file):
    with umask(INSTALLER_UMASK):
        wrapper = InstallWrapper(work_dir, options, ui, pwgen, out_file, err_file)
        wrapper.install()


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script should run as root")
        sys.exit(1)

    parser = optparse.OptionParser()
    parser.add_option("-a", "--advanced", action="store_true", default=False,
                      help="Advanced configuration options")
    parser.add_option("-r", "--release", default=DEFAULT_COOKBOOK_VERSION,
                      help="Installer release")
    parser.add_option("-p", "--passwords", action="store_true", default=False,
                      help="Use custom passwords")
    parser.add_option("-n", "--noprompt", action="store_true", default=False,
                      help="Do not prompt for notifications.")
    parser.add_option("-v", "--verbose", action="store_true", default=False,
                      help="Verbose logging (debug)")
    options, args = parser.parse_args()

    current_dir = os.getcwd()
    work_dir = tempfile.mkdtemp()

    out_log_path = os.path.join(current_dir, OUT_LOG)
    out_log = open(out_log_path, "w")

    err_log_path = os.path.join(current_dir, ERR_LOG)
    err_log = open(err_log_path, "w")

    try:
        os.chdir(work_dir)
        ui = UserInput(raw_input, print)
        pwgen = RandomPasswordGenerator(os.urandom)
        main(work_dir, options, ui, pwgen, out_log, err_log)
    except KeyboardInterrupt:
        print("Exiting on user interrupt")
    except Exception:
        print(traceback.format_exc())
        print("Whoops! Looks like the installer hit a snag!")
        print("Please file an issue: {0}".format(format_symbol(ISSUES_URL)))
        print("Please attach the following files, if present:")
        print(format_symbol(out_log_path))
        print(format_symbol(err_log_path))
    finally:
        if options.advanced:
            print("WARNING: Your SSH key may be stored on this server")
            print("Please check the attributes file, and SSH key file")

        os.chdir(current_dir)
