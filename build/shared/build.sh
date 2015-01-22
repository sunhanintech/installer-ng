#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# Constant
PKG_CLOUD_REPO_ROOT="scalr/scalr-server"

# What are we building?
: ${EE:="0"}

if [[ "${EE}" == "1" ]]; then
  git_repo="int-scalr"
  ee_flag="+ee"
  pkg_cloud_repo="${PKG_CLOUD_REPO_ROOT}-ee"
  installer_branch="omnibus-package.ee"
else
  git_repo="scalr"
  ee_flag=""
  pkg_cloud_repo="${PKG_CLOUD_REPO_ROOT}"
  installer_branch="omnibus-package"
fi

# This is a nightly build, we'd like to get the dates right.
export TZ="UTC"

# We'll need this for git
export GIT_SSH=/git_ssh_wrapper.sh

# Make git happier with some configuration. This is needed by Omnibus to
# make commits
git config --global user.email "builder@scalr.com"
git config --global user.name "Scalr Builder"

# Let's pull and install the installer first
git clone https://github.com/Scalr/installer-ng.git /installer-ng
cd /installer-ng
git checkout "${installer_branch}"
installer_git_version=$(git log -n 1 --date="local" --pretty=format:"%ct.%h")
bundle install --binstubs

# Clone repo
SCALR_APP_PATH="/opt/scalr"
SCALR_REVISION='master'

git clone "git@github.com:scalr/${git_repo}.git" "${SCALR_APP_PATH}"
cd "${SCALR_APP_PATH}"
git checkout "${SCALR_REVISION}"
scalr_git_version=$(git log -n 1 --date="local" --pretty=format:"%ct.%h")

# Identify OS now.
eval $(/installer-ng/bin/ohai | python -c '
import sys, json
ohai = json.load(sys.stdin)

if ohai["platform"] in ("centos", "redhat", "fedora"):
  print "PKG_CLOUD_PATH=el/{0}".format(ohai["platform_version"].split(".")[0])
  print "PKG_CODENAME=el.{0}".format(ohai["platform_version"].split(".")[0])
  print "PKG_EXTENSION=rpm"
elif ohai["platform"] == "ubuntu":
  print "PKG_CLOUD_PATH=ubuntu/{0}".format(ohai["platform_version"])
  print "PKG_CODENAME={0}".format(ohai["lsb"]["codename"])
  print "PKG_EXTENSION=deb"
elif ohai["platform"] == "debian":
  print "PKG_CLOUD_PATH=debian/{0}".format(ohai["platform_version"].split(".")[0])
  print "PKG_CODENAME={0}".format(ohai["lsb"]["codename"])
  print "PKG_EXTENSION=deb"
else:
  print "UNKNOWN PLATFORM!"
  sys.exit(1)
')

# Prepare the build
cd /installer-ng

# This is passed in the environment because it is respected there, and because we need to update it without updating
# the project file (which invalidates *everything*).
export SCALR_APP_PATH
export SCALR_VERSION="$(cat "${SCALR_APP_PATH}/app/etc/version")${ee_flag}~nightly.${scalr_git_version}.${installer_git_version}.${PKG_CODENAME}"

# Launch build
echo "Building: ${SCALR_VERSION}"
bin/omnibus build scalr-server

# Build suceeded!
package_cloud push "${pkg_cloud_repo}/${PKG_CLOUD_PATH}" pkg/scalr-server*.${PKG_EXTENSION}

