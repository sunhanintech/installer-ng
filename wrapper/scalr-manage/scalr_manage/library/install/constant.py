# coding:utf-8
import os


INSTALLER_UMASK = 0o22

CHEF_INSTALL_URL = "https://www.opscode.com/chef/install.sh"
COOKBOOK_PKG_URL_TPL = "https://s3.amazonaws.com/installer.scalr.com/releases/installer-ng-v{0}.tar.gz"

COOKBOOK_DIR = "cookbook"
CACHE_DIR = "cache"
SOLO_RB_FILE = "solo.rb"

CHEF_SOLO_PATHS = os.pathsep.join(["/opt/chef/bin", "/opt/chef/embedded/bin"])
CHEF_SOLO_BIN = "chef-solo"
RUBY_BIN = "ruby"
TAR_BIN = "tar"

MINIMUM_CHEF_VERSION = "11.0.0"
MINIMUM_RUBY_VERSION = "1.9.0"


DEFAULT_LOG_FILE = "/var/log/scalr-install.log"
