import os

from scalr_manage import cli

from scalr_manage.library.install.test.util import BaseInstallTestCase


class CliTestCase(BaseInstallTestCase):
    def test_error_noconfig(self):
        argv = ["scalr-manage", "document"]
        ret = cli._main(argv, self.ui, self.tokgen)
        self.assertEqual(-2, ret)


class InstallErrorTestCase(BaseInstallTestCase):
    def test_error_noconfig(self):
        os.environ["PATH"] = os.path.join(self.versions_path, "ok_chef")
        os.environ["MOCK_CHEF_EXIT_CODE"] = "1"

        log_file = os.path.join(self.work_dir, "log.log")

        # This uses its own parser and doesn't default to our solo.json path!
        argv = ["scalr-manage", "-c", self.solo_json_path, "install", "-l", log_file]
        ret = cli._main(argv, self.ui, self.tokgen)

        self.assertEqual(1, ret)
        self.assertTrue(any(log_file in msg for msg in self.output.outputs), "Path to log file wasn't printed!")
        for arg in argv:
            self.assertTrue(any(arg in msg for msg in self.output.outputs), "Arg {0} wasn't printed".format(arg))
