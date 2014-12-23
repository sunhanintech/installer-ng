# coding:utf-8
import logging

from scalr_manage import version
from scalr_manage.constant import VERSION_FLAG_FILE_EXT
from scalr_manage.library.base import Target
from scalr_manage.library.exception import ConfigurationException


logger = logging.getLogger(__name__)


class MatchVersionTarget(Target):
    name = "match-version"
    help = "Check if the current configuration file version matches the current installer version"

    def __call__(self, args, ui, tokgen):
        exit_code = 0

        # First, check if there even is a readable configuration
        try:
            self._check_configuration(args)
        except ConfigurationException:
            exit_code = 1
        else:

            # If there is a configuration, check whether the version matches
            try:
                with open(".".join([args.configuration, VERSION_FLAG_FILE_EXT])) as f:
                    # *We* never write a newline here, but let's be liberal in what we accept
                    current_config_version_string = f.read().strip()

                # It would be much cleaner to use an actual version parser for this (e.g. from the "packaging"
                # package), but it's arguably not worth pulling in another dependency just to check a major
                # version number.
                config_file_major_version = current_config_version_string.split(".", 1)[0]
                scalr_manage_major_version = version.__version__.split(".", 1)[0]

                if config_file_major_version != scalr_manage_major_version:
                    exit_code = 1

            except IOError:
                exit_code = 1

        raise SystemExit(exit_code)
