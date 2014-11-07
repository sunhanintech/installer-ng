# coding:utf-8
from __future__ import print_function

import argparse

from scalr_installer.library.configure.target import ConfigureTarget
from scalr_installer.library.install.target import InstallTarget
from scalr_installer.rnd import RandomTokenGenerator


def _main(argv, ui, tokgen):
    parser = argparse.ArgumentParser(description="Install and manage a Scalr host")

    parser.add_argument("-c", "--configuration", default="/etc/scalr.json",
                        help="Where to save the solo.json configuration file.")

    subparsers = parser.add_subparsers(title="subcommands")

    # TODO - Add config file

    for target in (ConfigureTarget(), InstallTarget()):
        parser = subparsers.add_parser(target.name, help=target.help)
        parser.set_defaults(target=target)
        target.register(parser)

    args = parser.parse_args(argv)

    args.target(args, ui, tokgen)


def main():
    import sys
    import os
    from scalr_installer.ui.engine import UserInput

    ui = UserInput(raw_input if sys.version_info < (3, 0, 0) else input, print)
    tokgen = RandomTokenGenerator(os.urandom)
    _main(sys.argv[1:], ui, tokgen)
