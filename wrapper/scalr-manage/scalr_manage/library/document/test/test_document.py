# coding:utf-8
from __future__ import unicode_literals

import os
import unittest
import testfixtures

from scalr_manage.library.document.target import DocumentTarget

from scalr_manage.test.util import TestParser


class DocumentTestCase(unittest.TestCase):
    def setUp(self):
        self.parser = TestParser()

        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.test_json = os.path.join(self.test_data, "solo.json")

    def test_document(self):
        class Container(object):
            pass

        args = Container()
        args.configuration = self.test_json


        target = DocumentTarget()
        with testfixtures.LogCapture() as l:
            target(args, None, None )

            actual = [r.getMessage() for r in l.records]
            for expected in [
                "Scalr is installed at: `/opt/scalr`",
                "Launch Scalr by browsing to `http://app.scalr.test`",
                "Username: `admin`",
                "Password: `scalrpass`",
                "Your scalr installation ID is: `i0xaaaaaaaa`",
                "`scalr`: `dbpass`",
            ]:
                self.assertTrue(expected in actual)


