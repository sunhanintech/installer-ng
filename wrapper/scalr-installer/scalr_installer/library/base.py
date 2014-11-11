# coding:utf-8


class Target(object):
    name = None
    help = None

    def register(self, parser):
        pass

    def __call__(self, args, ui, tokgen):
        pass
