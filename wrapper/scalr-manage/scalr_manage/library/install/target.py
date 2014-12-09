# coding:utf-8
from __future__ import unicode_literals

import os
import stat
import subprocess
import logging

from scalr_manage.version import __version__
from scalr_manage.constant import LOGGING_FORMAT
from scalr_manage.library.base import Target
from scalr_manage.library import exception
from scalr_manage.library.install import constant
from scalr_manage.library.install.constant import CHEF_SOLO_BIN
from scalr_manage.library.install.util import python, http


logger = logging.getLogger(__name__)


def has_compliant_chef():
    try:
        chef_version = python.check_output([constant.CHEF_SOLO_BIN, "-v"])
        _, ver = chef_version.split(" ")
        if ver < constant.MINIMUM_CHEF_VERSION:
            return False

        ruby_version = python.check_output([constant.RUBY_BIN, "-v"])
        _, ver, _ = ruby_version.split(" ", 2)
        if ver < constant.MINIMUM_RUBY_VERSION:
            return False

    except (ValueError, AttributeError, OSError, subprocess.CalledProcessError):
        # ValueError: we didn't recognize the version string
        # AttributeError, OSError: it's not installed
        # CalledProcessError: something crashed
        return False

    else:
        return True


def check_or_install_chef(args, work_dir, http_download):
    if not has_compliant_chef():
        logger.info("Chef is not installed -- installing it")
        installer = os.path.join(work_dir, os.path.basename(constant.CHEF_INSTALL_URL))
        http_download(constant.CHEF_INSTALL_URL, installer)
        os.chmod(installer, stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR)
        subprocess.check_call([installer])


# TODO - Remove if this is indeed not useful
def download_cookbook(args, work_dir, http_download):
    cookbook_url = constant.COOKBOOK_PKG_URL_TPL.format(args.release)
    cookbook_file = os.path.join(work_dir, os.path.basename(cookbook_url))
    logger.info("Downloading Scalr Cookbook: %s", cookbook_url)

    http_download(cookbook_url, cookbook_file)
    subprocess.check_call(["tar", "xzvf", cookbook_file, "-C", os.path.join(work_dir, constant.COOKBOOK_DIR)])


def create_solo_rb(args, work_dir, http_download):
    contents = """
    file_cache_path "{file_cache_path}"
    recipe_url      "{recipe_url}"
    log_level       {log_level}
    log_location    "{log_location}"
    json_attribs    "{json_attribs}"
    """.format(
        file_cache_path=os.path.join(work_dir, constant.CACHE_DIR),
        recipe_url=constant.COOKBOOK_PKG_URL_TPL.format(args.release),
        log_level=":debug" if args.verbose else ":info",
        log_location=args.log_file,
        json_attribs=args.configuration,
    )

    logger.debug("solo.rb: %s", contents)

    with open(os.path.join(work_dir, constant.SOLO_RB_FILE), "w") as f:
        f.write(contents.encode("utf-8"))


def install_scalr(args, work_dir, http_download):
    logger.info("Installing Scalr")
    subprocess.check_call([CHEF_SOLO_BIN, "--config", os.path.join(work_dir, constant.SOLO_RB_FILE)])


class InstallTarget(Target):
    name = "install"
    help = "Install or update Scalr on this host"

    def register(self, parser):
        parser.add_argument("-r", "--release", default=__version__, help="Installer cookbook release (e.g. 6.5.0)")
        parser.add_argument("-l", "--log-file", default=constant.DEFAULT_LOG_FILE)
        parser.add_argument("-v", "--verbose", action="store_true", help="Enable debug log output from Chef")

    def __call__(self, args, ui, tokgen):
        self._check_configuration(args)
        path = os.pathsep.join([constant.CHEF_SOLO_PATHS, os.environ["PATH"]])
        http_download = http.download

        # First, register the log file!
        # noinspection PyBroadException
        try:
            log_handler = logging.FileHandler(args.log_file)
        except Exception:
            logger.warning("Failed to setup logging to %s", args.log_file, exc_info=True)
        else:
            log_handler.setFormatter(logging.Formatter(LOGGING_FORMAT))
            logger.addHandler(log_handler)

        # Now, install!
        try:
            with python.path(path):
                logger.debug("PATH is: %s", path)
                with python.umask(constant.INSTALLER_UMASK):
                    with python.tmp_dir() as work_dir:
                        logger.debug("Work dir is: %s", work_dir)
                        for step in [check_or_install_chef, create_solo_rb, install_scalr]:
                            logger.info("Now performing installation step: %s", step.__name__)
                            step(args, work_dir, http_download)
        except Exception:
            logger.exception("Installation failed")
            raise exception.InstallerException(args.log_file)
