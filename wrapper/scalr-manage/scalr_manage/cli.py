# coding:utf-8
from __future__ import print_function

import subprocess
import argparse

from scalr_manage.library.configure.target import ConfigureTarget
from scalr_manage.library.install.target import InstallTarget
from scalr_manage.library.document.target import DocumentTarget
from scalr_manage.library.exception import ConfigurationException, InstallerException
from scalr_manage.library.subscribe.target import SubscribeTarget


def _main(argv, ui, tokgen):
    # TODO - Test!
    parser = argparse.ArgumentParser(description="Install and manage a Scalr host")

    parser.add_argument("-c", "--configuration", default="/etc/scalr.json",
                        help="Where to save the solo.json configuration file.")

    subparsers = parser.add_subparsers(title="subcommands")

    for target in (ConfigureTarget(), InstallTarget(), DocumentTarget(), SubscribeTarget()):
        subparser = subparsers.add_parser(target.name, help=target.help)
        subparser.set_defaults(target=target)
        target.register(subparser)

    args = parser.parse_args(argv[1:])  # Default behavior, only we're not directly using sys.argv here
    exit_code = 0

    try:
        args.target(args, ui, tokgen)
    except (KeyboardInterrupt, EOFError) as e:
        ui.print_fn("Exiting on user interrupt or end of input ({0})".format(e))
        exit_code = -1
    except ConfigurationException as e:
        ui.print_fn("Parsing the configuration file at {0} failed with: {1}.".format(e.path, e))
        ui.print_fn("Run 'scalr-manage configure' first.")
        exit_code = -2
    except InstallerException as e:
        ui.print_fn("Whoops! It looks like the installer hit a snag")
        ui.print_fn("Please file an issue to get support: https://github.com/scalr/installer-ng/issues")
        ui.print_fn("Please include the installer log file in your bug report: {0}".format(e.log_file))
        ui.print_fn("If this looks like a temporary issue, consider re-executing the installer command that failed by running")
        ui.print_fn("  {0}".format(subprocess.list2cmdline(argv)))
        exit_code = 1

    return exit_code


def main():
    import sys
    import os
    import logging

    import requests
    from raven.handlers.logging import SentryHandler
    from raven.conf import setup_logging

    from scalr_manage.ui.engine import UserInput
    from scalr_manage.rnd import RandomTokenGenerator
    from scalr_manage.constant import RAVEN_DSN_URL, RAVEN_DSN_CACHE_FILE, LOGGING_FORMAT

    # UI / random setup
    ui = UserInput(raw_input if sys.version_info < (3, 0, 0) else input, print)
    tokgen = RandomTokenGenerator(os.urandom)

    # Logging setup
    pre_parser = argparse.ArgumentParser(add_help=False)
    pre_parser.add_argument("--no-logging", default=False, action="store_true")
    pre_parser.add_argument("--verbose", default=False, action="store_true")
    ns, real_args = pre_parser.parse_known_args()

    root_handler = logging.StreamHandler()
    root_handler.setFormatter(logging.Formatter(LOGGING_FORMAT))

    root_logger = logging.getLogger()
    root_logger.addHandler(root_handler)
    root_logger.setLevel(logging.WARNING)

    installer_logger = logging.getLogger("scalr_manage")
    installer_logger.setLevel(logging.DEBUG if ns.verbose else logging.INFO)

    if not ns.no_logging:
        try:
            try:
                with open(RAVEN_DSN_CACHE_FILE) as f:
                    raven_dsn = f.read()
            except IOError:
                # Only print a warning the first time this is used
                ui.print_fn("Note: this installer will log fatal errors to Scalr. No personal data is "
                            "logged (only stack traces), but you can disable this behavior with the "
                            "--no-logging flag if this is a problem for you.")

                # Retrieve a remote token so that we can rotate the token without
                # needing to upgrade the installer.
                ui.print_fn("Please wait while fatal error logging is being configured... ", end="")
                sys.stdout.flush()
                raven_dsn = requests.get(RAVEN_DSN_URL).text.strip()
                ui.print_fn("Done!")
        except Exception as e:
            logger.warning("Failed to setup fatal exception logging. Don't worry: you can still proceed.", exc_info=True)
        else:
            handler = SentryHandler(raven_dsn, level=logging.ERROR)
            setup_logging(handler)

        try:
            # Try and cache the token for future access
            with open(RAVEN_DSN_CACHE_FILE, "w") as f:
                f.write(raven_dsn)
        except:
            # If this fails for any reason, we don't care
            pass

    real_args.insert(0, sys.argv[0])  # _main expects to have argv[0] be the program's name!
    sys.exit(_main(real_args, ui, tokgen))
