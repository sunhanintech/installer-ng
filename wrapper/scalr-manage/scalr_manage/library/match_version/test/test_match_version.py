# coding:utf-8
import os

from scalr_manage.version import __version__
from scalr_manage.library.match_version.target import MatchVersionTarget

from scalr_manage.test.util import BaseWrapperTestCase


class MatchVersionTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(MatchVersionTestCase, self).setUp()

        self.target = MatchVersionTarget()
        self.target.register(self.parser)
        os.makedirs(os.path.dirname(self.solo_json_path))

    def _helper_check_exit_code(self, args, exit_code):
        try:
            ns = self.parser.parse_args(args)
            self.target.__call__(ns, self.ui, self.tokgen)
        except SystemExit as e:
            self.assertEqual(exit_code, e.code)
        else:
            self.fail("SystemExit wasn't raised!")

    def test_match_version(self):
        for version, exit_code in [
            (__version__, 0),
            ("...", 1),
            ("a.b.c", 1)
        ]:
            cnf = os.path.join(self.work_dir, version + ".json")

            with open(cnf, "w") as f:
                f.write("{}")

            with open(cnf + ".version", "w") as f:
                f.write(version)

            self._helper_check_exit_code(["--configuration", cnf], exit_code)

    def test_no_version(self):
        self._helper_check_exit_code([], 1)

    def test_no_configuration(self):
        with open(self.solo_json_path + ".version", "w") as f:
            f.write(__version__)
        self._helper_check_exit_code([], 1)

    def test_broken_configuration(self):
        with open(self.solo_json_path, "w") as f:
            f.write("{")
        with open(self.solo_json_path + ".version", "w") as f:
            f.write(__version__)
        self._helper_check_exit_code([], 1)
