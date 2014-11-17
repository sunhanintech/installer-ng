# coding:utf-8
from __future__ import print_function

import argparse

from scalr_manage.library.configure.target import ConfigureTarget
from scalr_manage.library.install.target import InstallTarget
from scalr_manage.library.document.target import DocumentTarget


def _main(argv, ui, tokgen):
    parser = argparse.ArgumentParser(description="Install and manage a Scalr host")

    parser.add_argument("-c", "--configuration", default="/etc/scalr.json",
                        help="Where to save the solo.json configuration file.")

    subparsers = parser.add_subparsers(title="subcommands")

    for target in (ConfigureTarget(), InstallTarget(), DocumentTarget()):
        subparser = subparsers.add_parser(target.name, help=target.help)
        subparser.set_defaults(target=target)
        target.register(subparser)

    args = parser.parse_args(argv)

    args.target(args, ui, tokgen)


def main():
    import sys
    import os
    from scalr_manage.ui.engine import UserInput
    from scalr_manage.rnd import RandomTokenGenerator

    # TODO
    import logging
    logging.basicConfig(level=logging.DEBUG)

    ui = UserInput(raw_input if sys.version_info < (3, 0, 0) else input, print)
    tokgen = RandomTokenGenerator(os.urandom)
    _main(sys.argv[1:], ui, tokgen)
