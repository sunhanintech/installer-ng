# coding:utf-8
import os
import unittest
import shutil
from scalr_installer.library.install.target import has_compliant_chef


class ChefInstallTestCase(unittest.TestCase):
    def setUp(self):
        self.old_path = os.environ["PATH"]
        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.versions_path = os.path.join(self.test_data, "versions")

    def tearDown(self):
        os.environ["PATH"] = self.old_path

    def test_ok_chef(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")
        self.assertTrue(has_compliant_chef())

    def test_ko_chef(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "ko_chef")
        self.assertFalse(has_compliant_chef())

    def test_chef_install(self):
        # TODO - Setup a test dir and have that script drop a file there
        os.environ["PATH"] = os.path.join(self.versions_path, "ko_chef")
        def http_download(url, dest):
            with open(os.path.join(self.test_data, "dummy_chef_installer")) as src:
                with open(dest, "w") as dst:
                    shutil.copyfileobj(src, dst)

    # TODO Test the http download function
