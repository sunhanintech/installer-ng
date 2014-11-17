# coding:utf-8

# Supported versions
SCALR_VERSION_4_5 = "4.5"
SCALR_VERSION_5_0 = "5.0"
SUPPORTED_VERSIONS = [SCALR_VERSION_4_5, SCALR_VERSION_5_0]

# Deploy parmeters
SCALR_NAME = "scalr"
SCALR_DEPLOY_TO = "/opt/scalr"

# Defaults
DEFAULT_SCALR_REPO = "git://github.com/Scalr/scalr.git"
DEFAULT_SCALR_GIT_REV = SCALR_VERSION_5_0
DEFAULT_SCALR_VERSION = SCALR_VERSION_5_0

# Other useful constants
GIT_NON_SSH_SCHEMES = ["http", "https", "git", "file"]
