# coding:utf-8
import os
import tempfile
import unittest
import shutil

from scalr_manage.library.install.target import has_compliant_chef, check_or_install_chef, InstallTarget
from scalr_manage.library.install.util import http
from scalr_manage.library import exception
from scalr_manage.rnd import RandomTokenGenerator

from scalr_manage.test.util import TestParser
from scalr_manage.ui.engine import UserInput
from scalr_manage.ui.test.util import MockInput, MockOutput


class BaseInstallTestCase(unittest.TestCase):
    def setUp(self):
        self.work_dir = tempfile.mkdtemp()
        os.environ["WORK_DIR"] = self.work_dir

        self.old_path = os.environ["PATH"]
        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.versions_path = os.path.join(self.test_data, "versions")

        self.parser = TestParser()

    def tearDown(self):
        os.environ["PATH"] = self.old_path
        shutil.rmtree(self.work_dir)


class ChefInstallTestCase(BaseInstallTestCase):
    def test_ok_chef(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")
        self.assertTrue(has_compliant_chef())

    def test_ko_chef(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "ko_chef")
        self.assertFalse(has_compliant_chef())

    def test_no_chef(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "no_chef")
        self.assertFalse(has_compliant_chef())

    def test_chef_install(self):
        # TODO - Setup a test dir and have that script drop a file there
        os.environ["PATH"] = os.path.join(self.versions_path, "ko_chef")

        def http_download(url, dest):
            with open(os.path.join(self.test_data, "dummy_chef_installer")) as src:
                with open(dest, "w") as dst:
                    shutil.copyfileobj(src, dst)

        check_or_install_chef(None, self.work_dir, http_download)
        self.assertTrue(os.path.exists(os.path.join(self.work_dir, "flag")))

    def test_http_download(self):
        dest = os.path.join(self.work_dir, "test_data")
        #TODO - Fix this
        http.download("https://httpbin.org/bytes/16", dest)
        with open(dest) as f:
            self.assertEqual(16, len(f.read()))


class ScalrInstallTestCase(BaseInstallTestCase):
    def setUp(self):
        super(ScalrInstallTestCase, self).setUp()

        # TODo Dedup with FullTestCase
        self.input = MockInput()
        self.output = MockOutput()
        self.ui = UserInput(self.input, self.output)

        self.tokgen = RandomTokenGenerator(os.urandom)

        self.parser = TestParser()
        self.parser.add_argument("--configuration", default=os.path.join(self.test_data, "test.json"))

        self.target = InstallTarget()
        self.target.register(self.parser)

        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")

    def tearDown(self):
        super(ScalrInstallTestCase, self).tearDown()
        try:
            del os.environ["MOCK_CHEF_EXIT_CODE"]
        except KeyError:
            pass

    def test_install_ok(self):
        os.environ["MOCK_CHEF_EXIT_CODE"] = "0"
        args = self.parser.parse_args(["--log-file", os.path.join(self.work_dir, "install.log")])
        self.target(args, self.ui, self.tokgen)

    def test_install_fail(self):
        os.environ["MOCK_CHEF_EXIT_CODE"] = "1"
        args = self.parser.parse_args(["--log-file", os.path.join(self.work_dir, "install.log")])
        self.assertRaises(exception.InstallerException, self.target, args, self.ui, self.tokgen)
