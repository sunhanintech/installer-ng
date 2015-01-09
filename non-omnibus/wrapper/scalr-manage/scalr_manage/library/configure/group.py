# coding:utf-8
from __future__ import unicode_literals

import os
import operator
import logging
import urlparse
from distutils.spawn import find_executable

from scalr_manage.library.configure import constant
from scalr_manage.sentry.constant import RAVEN_DSN_ENV_VAR
from scalr_manage.version import __version__


logger = logging.getLogger(__name__)


class Group(object):
    name        = None
    recipes     = None
    priority    = None
    optional    = False

    @classmethod
    def groups(cls):
        # TODO - Somewhat hackish, because they *need* to be imported.
        return sorted(cls.__subclasses__(), key=operator.attrgetter("priority"))

    @classmethod
    def _group_arg_name(cls):
        return "group_{0}".format(cls.name)

    @classmethod
    def is_enabled(cls, args):
        """
        :rtype : bool
        """
        if not cls.optional:
            return True

        # If this is specified, return what was specified, otherwise look at --without-all, as the default behavior
        # is to enable all.
        enabled = getattr(args, cls._group_arg_name())
        return enabled if enabled is not None else not args.without_all

    @classmethod
    def register_arguments(cls, parser):
        """
        Called when registering this Group with the argument parser.
        """
        if cls.optional:
            dest = cls._group_arg_name()
            arg_group = parser.add_mutually_exclusive_group()
            arg_group.add_argument("--without-{0}".format(cls.name), action="store_false", dest=dest,
                                   help="Disable {0} group".format(cls.name))
            arg_group.add_argument("--with-{0}".format(cls.name), action="store_true", dest=dest,
                                   help="Enable {0} group".format(cls.name))
            parser.set_defaults(**{dest: None})


    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        """
        Called to have this Group generate attributes (possibly by prompting the user for them)
        :rtype : dict
        """
        return {}


class LoggingGroup(Group):
    name        = "logging"
    recipes     = ["chef-sentry-handler"]
    priority    = 0
    optional    = False  # This only gets enabled if the env var is set

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        raven_dsn = os.environ.get(RAVEN_DSN_ENV_VAR)
        return {"sentry": {
            "enabled": raven_dsn is not None,
            "dsn": raven_dsn
        }}


class PolicyGroup(Group):
    name        = "policy"
    recipes     = ["apparmor", "selinux::disabled"]
    priority    = 2  # Disable very early
    optional    = True


class UtilGroup(Group):
    name        = "util"
    recipes     = ["apt", "yum", "build-essential", "rackspace_timezone"]
    priority    = 5
    optional    = False

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        return {
            "apt" : {"compile_time_update": True},
            "rackspace_timezone": {
                "config": {
                    "tz": "UTC"
                }
            }
        }


class NtpGroup(Group):
    name        = "ntp"
    recipes     = ["ntp"]
    priority    = 10
    optional    = True

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        output = {"ntp": {}}
        if PolicyGroup.is_enabled(args) or find_executable("aa-status") is None:
            # Disable apparmor in the ntp cookbook if apparmor is not enabled / installed.
            output['ntp']['apparmor_enabled'] =  False
        return output


class MysqlGroup(Group):
    name        = "mysql"
    recipes     = ["scalr-core::group_mysql"]
    priority    = 20
    optional    = True

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        output = {"mysql": {}, "scalr": {}}

        mysql_passwords = ["server_root_password", "server_debian_password",
                           "server_repl_password"]

        for mysql_password in mysql_passwords:
            output["mysql"][mysql_password] = tokgen.make_password(30)

        # The MySQL group takes care of setting up databases and users,
        # so we need to configure them here, even if they are a "Scalr"
        # attribute. We do it that way so that we don't have to allow
        # remote root.

        # TODO - Variabilize.
        output["scalr"]["database"] = {
            "host": "127.0.0.1",
            "port": 3306,
            "username": "scalr",
            "password": tokgen.make_password(30)
        }

        return output


class AppGroup(Group):
    name        = "app"
    recipes     = ["scalr-core::group_app"]
    priority    = 30
    optional    = True

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        output = {"scalr": {}}

        if not args.advanced:
            repo = constant.DEFAULT_SCALR_REPO
            revision = constant.DEFAULT_SCALR_GIT_REV
            version = constant.DEFAULT_SCALR_VERSION
        else:
            repo = ui.prompt("Enter the repository to clone (e.g. git@github.com:Scalr/scalr.git)")
            revision = ui.prompt("Enter the revision to deploy (e.g. HEAD)")
            version = ui.prompt_select_from_options("What Scalr version is this?", constant.SUPPORTED_VERSIONS)

        output["scalr"]["package"] = {
            "revision": revision,
            "repo": repo,
            "version": version,
            "name": constant.SCALR_NAME,
            "deploy_to": constant.SCALR_DEPLOY_TO,
        }

        # Deployment credentials options

        # Check whether we'll need to use a private key
        # It might seem contradictory to check for "non-SSH" schemes, but we
        # do this because no one ever puts ssh:// in their git URLs.
        if urlparse.urlparse(repo).scheme in constant.GIT_NON_SSH_SCHEMES:
            ui.print_fn("You will not need a SSH key for this repository ({0}).".format(repo))
            ssh_key = ""
        else:
            ssh_key = ui.prompt_ssh_key("Provide a SSH Key for this repository (password-based SSH isn't supported). "
                                        "If this seems wrong, provide a full URL (e.g. file:// ...)")

        output["scalr"]["deployment"] = {
            "ssh_key": ssh_key,
        }

        # Endpoint Settings

        host_ip = ui.prompt_ipv4("Enter the IPv4 address this Scalr server "
                                 "will use to connect to your cloud instances. "
                                 "This is used to setup cloud security groups.",
                                 "This is not a valid IP")

        if ui.prompt_yes_no("Should cloud instances also use {0} to connect to this Scalr server?".format(host_ip)):
            host = host_ip
        else:
            host = ui.prompt("Enter the host your cloud instances should connect to to reach this Scalr server. This "
                             "does NOT need to be an IP, and will NOT be validated (so be extra careful!).")

        if version == constant.SCALR_VERSION_4_5_0:
            local_ip = ui.prompt_ipv4("Enter the local IP incoming traffic reaches this instance through. Unless you "
                                      "are using NAT or a Cloud Elastic IP, this should be the same IP")
        else:
            local_ip = ""

        output["scalr"]["endpoint"] = {
            "scheme": "http",  # TODO
            "host": host,
            "host_ip": host_ip,
            "local_ip": local_ip,
            }

        # Scalr configuration

        conn_policy = ui.prompt_select_from_options("To connect to your instances, should Scalr use the private IP, "
                                                    "public IP, or automatically choose the best one? If unsure, use "
                                                    "`auto`", ["auto", "public", "local"])
        output["scalr"]["instances_connection_policy"] = conn_policy

        output["scalr"]["admin"] = {
            "username": "admin",
            "password": tokgen.make_password(15)
        }

        output["scalr"]["id"] = tokgen.make_id(__version__)

        # If MySQL is not going to be installed here, then we need
        # to get configuration from the user.

        if not MysqlGroup.is_enabled(args):
            ui.print_fn("No database will be installed. Provide database configuration details.")

            db_host = ui.prompt("MySQL host (IP or hostname, this will NOT be validated)")
            db_port = ui.prompt_integer("MySQL port")
            db_user = ui.prompt("MySQL username")
            db_pass = ui.prompt("MySQL password")

            output["scalr"]["database"] = {
                "host": db_host,
                "port": db_port,
                "username": db_user,
                "password": db_pass
            }

        return output


class IptablesGroup(Group):
    name        = "iptables"
    recipes     = ["iptables-ng"]
    priority    = 40
    optional    = True

    @classmethod
    def enabled_iptables_versions(cls):
        if os.path.exists(constant.IPV6_IF):
            return [4, 6]
        else:
            logger.warning("Not enabling iptables management for IPv6: protocol version appears to be disabled")
            return [4]

    @classmethod
    def make_attributes(cls, args, ui, tokgen):
        input_rules = {}
        if MysqlGroup.is_enabled(args):
            input_rules.update({
                "scalr-mysql": {
                    # TODO _ Variabilize
                    "rule": "--protocol tcp --dport 3306 --match state --state NEW --jump ACCEPT",
                }
            })
        if AppGroup.is_enabled(args):
            input_rules.update({
                "scalr-web": {
                    # TODO _ Variabilize
                    "rule": "--protocol tcp --dport 80 --match state --state NEW --jump ACCEPT",
                },
                "scalr-plotter": {
                    # TODO _ Variabilize
                    "rule": "--protocol tcp --dport 8080 --match state --state NEW --jump ACCEPT"
                },
            })
        return {"iptables-ng": {
            "enabled_ip_versions": cls.enabled_iptables_versions(),
            "rules": {"filter": {"INPUT": input_rules}}}
        }
