# coding:utf-8
import os
import shutil
import tempfile

from scalr_manage.test.util import BaseWrapperTestCase


class BaseInstallTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(BaseInstallTestCase, self).setUp()

        self.work_dir = tempfile.mkdtemp()
        os.environ["WORK_DIR"] = self.work_dir

        self.old_path = os.environ["PATH"]
        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.versions_path = os.path.join(self.test_data, "versions")

    def tearDown(self):
        os.environ["PATH"] = self.old_path
        shutil.rmtree(self.work_dir)

        try:
            del os.environ["MOCK_CHEF_EXIT_CODE"]
        except KeyError:
            pass