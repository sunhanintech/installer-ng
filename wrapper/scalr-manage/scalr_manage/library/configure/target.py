# coding:utf-8
from __future__ import unicode_literals

import os
import logging
import json
from scalr_manage import version

from scalr_manage.constant import VERSION_FLAG_FILE_EXT
from scalr_manage.library.base import Target
from scalr_manage.library.configure.group import Group
from scalr_manage.library.configure.util import merge


logger = logging.getLogger(__name__)


class ConfigureTarget(Target):
    name = "configure"
    help = "Configure this Scalr install"

    def register(self, parser):
        parser.add_argument("-a", "--advanced", action="store_true", default=False, help="Offer advanced configuration")
        parser.add_argument("-p", "--passwords", action="store_true", default=False, help="Use custom passwords")

        parser.add_argument("--without-all", default=False, action="store_true", help="Disable all groups")

        for groupCls in Group.groups():
            groupCls.register_arguments(parser)

    # noinspection PyMethodMayBeStatic
    def make_attributes(self, args, ui, tokgen):
        attributes = {}
        for groupCls in Group.groups():
            if groupCls.is_enabled(args):
                merge(attributes, groupCls.make_attributes(args, ui, tokgen))
        return attributes

    def make_runlist(self, args):
        runlist = []
        for groupCls in Group.groups():
            if groupCls.is_enabled(args):
                runlist.extend(map(lambda s: "recipe[{0}]".format(s), groupCls.recipes))
        return runlist

    def __call__(self, args, ui, tokgen):
        attributes = self.make_attributes(args, ui, tokgen)
        runlist = self.make_runlist(args)
        output = merge(dict(attributes), {"run_list": runlist})

        # TODO - Mode
        try:
            os.makedirs(os.path.dirname(args.configuration))
        except OSError:
            pass
        else:
            logger.warning("Directory did not exist for `{0}`, created it".format(args.configuration))

        # TODO - Warn if the file already exists!
        with open(args.configuration, "w") as f:
            logger.info("Generated configuration in: %s", f.name)
            json.dump(output, f, indent=4)

        with open(".".join([args.configuration, VERSION_FLAG_FILE_EXT]), "w") as f:
            logger.info("Logged configuration version in: %s", f.name)
            f.write(version.__version__)
