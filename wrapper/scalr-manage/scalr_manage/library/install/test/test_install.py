# coding:utf-8
import os
import shutil

from scalr_manage.library.install.target import has_compliant_chef, check_or_install_chef, InstallTarget
from scalr_manage.library.install.util import http
from scalr_manage.library import exception

from scalr_manage.library.install.test.util import BaseInstallTestCase


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

        self.target = InstallTarget()
        self.target.register(self.parser)

        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")


    def test_install_ok(self):
        os.environ["MOCK_CHEF_EXIT_CODE"] = "0"
        args = self.parser.parse_args(["--log-file", os.path.join(self.work_dir, "install.log")])
        self.target(args, self.ui, self.tokgen)

    def test_install_fail(self):
        os.environ["MOCK_CHEF_EXIT_CODE"] = "1"
        args = self.parser.parse_args(["--log-file", os.path.join(self.work_dir, "install.log")])
        self.assertRaises(exception.InstallerException, self.target, args, self.ui, self.tokgen)
