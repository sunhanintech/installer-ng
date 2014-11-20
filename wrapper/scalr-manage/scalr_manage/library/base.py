# coding:utf-8
import json

from scalr_manage.library import exception


class Target(object):
    name = None
    help = None

    def register(self, parser):
        pass

    def __call__(self, args, ui, tokgen):
        pass

    def _check_configuration(self, args):
        path = args.configuration
        try:
            with open(path) as f:
                json.load(f)
        except IOError:
            raise exception.NoConfigurationException(path)
        except ValueError:
            raise exception.InvalidConfigurationException(path)
