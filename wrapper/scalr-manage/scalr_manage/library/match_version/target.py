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
                    # We never write a newline here, but let's be liberal in what we accept
                    if f.read().strip() != version.__version__:
                        exit_code = 1
            except IOError:
                exit_code = 1

        raise SystemExit(exit_code)
