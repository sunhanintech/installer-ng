import unittest
import os

from scalr_manage import cli
from scalr_manage.rnd import RandomTokenGenerator
from scalr_manage.ui.engine import UserInput

from scalr_manage.ui.test.util import MockOutput, MockInput


class CliTestCase(unittest.TestCase):
    def setUp(self):
        self.input = MockInput()
        self.output = MockOutput()
        self.ui = UserInput(self.input, self.output)

        self.tokgen = RandomTokenGenerator(os.urandom)

    def test_error_noconfig(self):
        argv = ["document"]
        ret = cli._main(argv, self.ui, self.tokgen)
        self.assertEqual(-2, ret)
