import os

from scalr_manage import cli
from scalr_manage.constant import COMMAND_OVERRIDE_VARIABLE

from scalr_manage.library.install.test.util import BaseInstallTestCase


class CliTestCase(BaseInstallTestCase):
    def test_error_noconfig(self):
        argv = ["scalr-manage", "document"]
        ret = cli._main(argv, self.ui, self.tokgen)
        self.assertEqual(-2, ret)


class InstallErrorTestCase(BaseInstallTestCase):
    EXTRA_ENV_CLEANUP_KEYS = [COMMAND_OVERRIDE_VARIABLE]

    def setUp(self):
        super(InstallErrorTestCase, self).setUp()

        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")
        os.environ["MOCK_CHEF_EXIT_CODE"] = "1"

        self.log_file = os.path.join(self.work_dir, "log.log")
        self.argv = ["scalr-manage", "-c", self.solo_json_path, "install", "-l", self.log_file]

    def _crash_and_assert(self):
        # This command fails because solo_json_path doesn't exist.
        ret = cli._main(self.argv, self.ui, self.tokgen)

        self.assertEqual(1, ret)
        self.assertTrue(any(self.log_file in msg for msg in self.output.outputs), "Path to log file wasn't printed!")

    def test_error_no_override(self):
        self._crash_and_assert()
        for arg in self.argv:
            self.assertTrue(any(arg in msg for msg in self.output.outputs), "Arg {0} wasn't printed".format(arg))

    def test_error_empty_override(self):
        os.environ[COMMAND_OVERRIDE_VARIABLE] = ""

        self._crash_and_assert()
        for arg in self.argv:
            self.assertTrue(any(arg in msg for msg in self.output.outputs), "Arg {0} wasn't printed".format(arg))

    def test_error_override(self):
        cmd = "some command that is not found anywhere in the regular output"
        os.environ[COMMAND_OVERRIDE_VARIABLE] = cmd

        self._crash_and_assert()
        self.assertTrue(any(cmd in msg for msg in self.output.outputs), "Override was not printed!")
