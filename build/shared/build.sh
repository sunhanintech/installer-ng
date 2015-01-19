#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

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
git checkout omnibus-package
bundle install --binstubs

# Constants
SCALR_REPO="/opt/scalr"
SCALR_REVISION='master'

PKG_CLOUD_REPO="scalr/scalr-server"

# What are we building?
: ${EE:="0"}

if [[ "${EE}" == "1" ]]; then
  repo="int-scalr"
  repo_flag="+ee"
else
  repo="scalr"
  repo_flag=""
fi

# Clone repo
git clone "git@github.com:scalr/${repo}.git" "${SCALR_REPO}"
cd "${SCALR_REPO}"
git checkout "${SCALR_REVISION}"
git_version=$(git log -n 1 --date="local" --pretty=format:"%ct.%h")

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

# Prepare environment
export SCALR_REPO
export SCALR_REVISION
export SCALR_VERSION="$(cat "${SCALR_REPO}/app/etc/version")${repo_flag}~nightly.${git_version}.${PKG_CODENAME}"

# Launch build
cd /installer-ng
bin/omnibus build scalr-server

# Build suceeded!
package_cloud push "${PKG_CLOUD_REPO}/${PKG_CLOUD_PATH}" pkg/scalr-server*.${PKG_EXTENSION}

