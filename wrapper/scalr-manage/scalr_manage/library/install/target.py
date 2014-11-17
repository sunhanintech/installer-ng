# coding:utf-8
from __future__ import unicode_literals

import os
import stat
import subprocess
import logging

from scalr_manage.version import __version__
from scalr_manage.library.base import Target
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

    except (ValueError, AttributeError, subprocess.CalledProcessError):
        # ValueError: we didn't recognize the version string
        # AttributeError: it's not installed
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
    json_attribs    "{json_attribs}"
    """.format(
        file_cache_path=os.path.join(work_dir, constant.CACHE_DIR),
        recipe_url=constant.COOKBOOK_PKG_URL_TPL.format(args.release),
        log_level=":debug" if args.verbose else ":info",
        json_attribs=args.configuration,
    )

    logger.debug("solo.rb: %s", contents)

    with open(os.path.join(work_dir, constant.SOLO_RB_FILE), "w") as f:
        f.write(contents.encode("utf-8"))


def install_scalr(args, work_dir, http_download):
    logger.info("Installing Scalr")
    proc = subprocess.Popen([CHEF_SOLO_BIN, "--config", os.path.join(work_dir, constant.SOLO_RB_FILE)])
    proc.wait()
    # TODO - Check retcode


class InstallTarget(Target):
    name = "install"
    help = "Install or update Scalr on this host"

    def register(self, parser):
        # TODO - This needs to be indexed somewhere!
        parser.add_argument("-r", "--release", default=__version__, help="Installer cookbook release (e.g. 6.5.0)")
        parser.add_argument("-v", "--verbose", help="Enable debug log output from Chef")

    def __call__(self, args, ui, tokgen):
        path = os.pathsep.join([constant.CHEF_SOLO_PATHS, os.environ["PATH"]])
        http_download = http.download
        with python.path(path):
            logger.debug("PATH is: %s", path)
            with python.umask(constant.INSTALLER_UMASK):
                with python.tmp_dir() as work_dir:
                    logger.debug("Work dir is: %s", work_dir)
                    for step in [check_or_install_chef, create_solo_rb, install_scalr]:
                        logger.info("Now performing installation step: %s", step.__name__)
                        step(args, work_dir, http_download)
