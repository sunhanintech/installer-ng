# coding:utf-8
import os
import shutil

from scalr_manage.test.util import BaseWrapperTestCase


class BaseInstallTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(BaseInstallTestCase, self).setUp()

        # Used for our tests
        os.environ["WORK_DIR"] = self.work_dir

        # Used to restore the PATH afterwards
        self.old_path = os.environ["PATH"]

        # Where is our data?
        self.test_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "test_data")
        self.versions_path = os.path.join(self.test_data, "versions")

        # Add configuration files in place
        os.makedirs(os.path.join(os.path.dirname(self.solo_json_path)))
        shutil.copyfile(os.path.join(self.test_data, "test.json"), self.solo_json_path)

    def tearDown(self):
        super(BaseInstallTestCase, self).tearDown()

        os.environ["PATH"] = self.old_path

        for k in ["MOCK_CHEF_EXIT_CODE", "WORK_DIR"]:
            try:
                del os.environ[k]
            except KeyError:
                pass

