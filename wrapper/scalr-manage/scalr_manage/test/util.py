# coding:utf-8
from argparse import ArgumentParser


class ParsingError(Exception):
    """
    Re-raise argparse errors as those, so that we don't trap exits.
    """
    def __init__(self, status, message):
        self.status = status
        self.message = message


class TestParser(ArgumentParser):
    def exit(self, status=0, message=None):
        raise ParsingError(status, message)

