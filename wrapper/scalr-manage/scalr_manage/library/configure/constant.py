# coding:utf-8

# Supported versions
SCALR_VERSION_4_5 = "4.5"
SCALR_VERSION_5_0_0 = "5.0"
SCALR_VERSION_5_0_1 = "5.0.1"
SCALR_VERSION_5_1 = "5.1"
SCALR_VERSION_5_1_1 = "5.1.1"
SUPPORTED_VERSIONS = [
    SCALR_VERSION_4_5,
    SCALR_VERSION_5_0_0, SCALR_VERSION_5_0_1,
    SCALR_VERSION_5_1, SCALR_VERSION_5_1_1
]

# Deploy parmeters
SCALR_NAME = "scalr"
SCALR_DEPLOY_TO = "/opt/scalr"

# Defaults
DEFAULT_SCALR_REPO = "git://github.com/Scalr/scalr.git"
DEFAULT_SCALR_VERSION = SCALR_VERSION_5_1
DEFAULT_SCALR_GIT_REV = DEFAULT_SCALR_VERSION  # Corresponding branch

# Other useful constants
GIT_NON_SSH_SCHEMES = ["http", "https", "git", "file"]


# Used to check for IPv6
IPV6_IF = "/proc/net/if_inet6"
