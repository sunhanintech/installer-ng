# coding:utf-8
import os
import tempfile
import unittest
from argparse import ArgumentParser

from scalr_manage.rnd import RandomTokenGenerator
from scalr_manage.ui.engine import UserInput

from scalr_manage.ui.test.util import MockInput, MockOutput


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


class BaseWrapperTestCase(unittest.TestCase):
    def setUp(self):
        self.work_dir = tempfile.mkdtemp()
        self.solo_json_path = os.path.join(self.work_dir, "scalr", "solo.json")

        self.input = MockInput()
        self.output = MockOutput()
        self.ui = UserInput(self.input, self.output)

        self.tokgen = RandomTokenGenerator(os.urandom)

        self.parser = TestParser()
        self.parser.add_argument("--configuration", default=self.solo_json_path)

