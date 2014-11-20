# coding:utf-8
from __future__ import unicode_literals

import os
import unittest

from scalr_manage.library.document.target import DocumentTarget
from scalr_manage.library.exception import ConfigurationException
from scalr_manage.rnd import RandomTokenGenerator
from scalr_manage.ui.engine import UserInput

from scalr_manage.test.util import TestParser
from scalr_manage.ui.test.util import MockOutput, MockInput


class Container(object):
    pass


class DocumentTestCase(unittest.TestCase):
    def setUp(self):
        self.input = MockInput()
        self.output = MockOutput()
        self.ui = UserInput(self.input, self.output)

        self.tokgen = RandomTokenGenerator(os.urandom)

        self.parser = TestParser()

        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.test_json = os.path.join(self.test_data, "solo.json")
        self.fail_json = os.path.join(self.test_data, "fail.json")
        self.no_json = os.path.join(self.test_data, "does-not-exist.json")

    def test_document(self):
        args = Container()
        args.configuration = self.test_json

        target = DocumentTarget()
        target(args, self.ui, self.tokgen)

        for expected in [
            "Scalr is installed at: `/opt/scalr`",
            "Launch Scalr by browsing to `http://app.scalr.test`",
            "Username: `admin`",
            "Password: `scalrpass`",
            "Your scalr installation ID is: `i0xaaaaaaaa`",
            "`scalr`: `dbpass`",
            ]:
            self.assertTrue(expected in self.output.outputs)

    def test_no_configuration(self):
        args = Container()
        args.configuration = self.no_json

        target = DocumentTarget()
        self.assertRaises(ConfigurationException, target, args, self.ui, self.tokgen)

    def test_invalid_configuration(self):
        args = Container()
        args.configuration = self.fail_json

        target = DocumentTarget()
        self.assertRaises(ConfigurationException, target, args, self.ui, self.tokgen)
