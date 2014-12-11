# coding:utf-8
from __future__ import unicode_literals
import json
import os
import shutil
import unittest

from scalr_manage.library.configure.target import ConfigureTarget

from scalr_manage.test.util import ParsingError, TestParser, BaseWrapperTestCase


APP_TEST_INPUTS = [
    "https://github.com/Scalr/scalr.git",
    "master",
    "5.0",
    "127.0.0.1",
    "n",
    "localhost",
    "auto",
]

APP_TEST_NO_MYSQL_INPUTS = APP_TEST_INPUTS + [
    "192.168.1.1",
    "3306",
    "scalr",
    "scalr123",
]


class ArgumentsTestCase(unittest.TestCase):
    def setUp(self):
        self.parser = TestParser()

    def test_arg_generation(self):
        # Check that the right args are being generated
        ConfigureTarget().register(self.parser)

        self.parser.parse_args(["--without-ntp"])
        self.parser.parse_args(["--with-ntp"])
        self.assertRaises(ParsingError, self.parser.parse_args, ["--without-util"])
        self.assertRaises(ParsingError, self.parser.parse_args, ["--without-zzz"])


class AttributesTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(AttributesTestCase, self).setUp()

        self.target = ConfigureTarget()
        self.target.register(self.parser)

    def test_make_attributes_empty(self):
        argv = ["--without-all"]

        self.assertEqual(
            {'apt': {'compile_time_update': True}, 'sentry': {'dsn': None, 'enabled': False}},
            self.target.make_attributes(self.parser.parse_args(argv), self.ui, self.tokgen)
        )

    def test_make_attributes_app_without_mysql(self):
        argv = ["--advanced", "--without-all", "--with-app"]
        args = self.parser.parse_args(argv)

        self.input.inputs = list(APP_TEST_INPUTS)
        self.assertRaises(IndexError, self.target.make_attributes, args, self.ui, self.tokgen)

        self.input.inputs = list(APP_TEST_NO_MYSQL_INPUTS)
        attrs = self.target.make_attributes(args, self.ui, self.tokgen)
        self.assertEqual(0, len(self.input.inputs))

        self.assertEqual(4, len(attrs["scalr"]["database"]))

    def test_make_attributes_app_with_mysql(self):
        argv = ["--advanced", "--without-all", "--with-app", "--with-mysql"]
        args = self.parser.parse_args(argv)

        self.input.inputs = list(APP_TEST_INPUTS)
        attrs = self.target.make_attributes(args, self.ui, self.tokgen)
        self.assertEqual(0, len(self.input.inputs))

        self.assertEqual(4, len(attrs["scalr"]["database"]))

    def test_make_runlist(self):
        common = ["recipe[chef-sentry-handler]", "recipe[apt]", "recipe[build-essential]", "recipe[timezone-ii]"]
        test_cases = [
            (common, ["--without-all"]),
            (common + ["recipe[scalr-core::group_mysql]", "recipe[scalr-core::group_app]"],
             ["--without-ntp", "--without-iptables"]),
        ]
        for expected, args in test_cases:
            self.assertEqual(expected, self.target.make_runlist(self.parser.parse_args(args)))
        self.assertEqual(8, len(self.target.make_runlist(self.parser.parse_args([]))))


class IptablesAttributesDiscoveryTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(IptablesAttributesDiscoveryTestCase, self).setUp()

        self.target = ConfigureTarget()
        self.target.register(self.parser)

        self.__real_path_exists = os.path.exists
        os.path.exists = lambda path: self.mock_path_exists(path)

        self.mock_path_exists = lambda path: 1/0  # Override me !

    def tearDown(self):
        os.path.exists = self.__real_path_exists

    def _helper_get_iptables_ng_attrs(self):
        argv = ["--without-all", "--with-iptables"]
        attrs = self.target.make_attributes(self.parser.parse_args(argv), self.ui, self.tokgen)
        self.assertTrue("iptables-ng" in attrs)
        return attrs["iptables-ng"]

    def test_all_ip_protos(self):
        self.mock_path_exists = lambda path: path == "/proc/net/if_inet6"
        iptables_ng_attrs = self._helper_get_iptables_ng_attrs()
        self.assertEqual([4, 6], iptables_ng_attrs["enabled_ip_versions"])

    def test_no_ipv6(self):
        self.mock_path_exists = lambda path: False
        iptables_ng_attrs = self._helper_get_iptables_ng_attrs()
        self.assertEqual([4,], iptables_ng_attrs["enabled_ip_versions"])


class FullTestCase(BaseWrapperTestCase):
    def setUp(self):
        super(FullTestCase, self).setUp()

        self.target = ConfigureTarget()
        self.target.register(self.parser)

    def tearDown(self):
        shutil.rmtree(self.work_dir)

    def test_solo_json_creation(self):
        self.input.inputs = list(APP_TEST_INPUTS)
        args = self.parser.parse_args(["--advanced"])
        self.target.__call__(args, self.ui, self.tokgen)
        with open(self.solo_json_path) as f:
            attrs = json.load(f)
        self.assertTrue(len(attrs) > 2)
        self.assertTrue("run_list" in attrs)
        self.assertTrue("scalr" in attrs)
        self.assertTrue("mysql" in attrs)
