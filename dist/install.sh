#!/bin/sh
set -o errexit
set -o nounset

if [ "$(id -u)" != "0" ]; then
  echo "You should run this installation script as root (or with sudo)!" 1>&2
  exit 1
fi

# Check OS -- exit if the OS is unsupported
python -c "
import sys
import platform

SUPPORTED_DISTROS = ['ubuntu', 'redhat', 'centos']
distro, _, _ = map(lambda s: s.lower(), platform.linux_distribution(full_distribution_name=False))
if distro not in SUPPORTED_DISTROS:
    print \"Distribution '{0}' is not supported -- use one of: {1}\".format(distro, SUPPORTED_DISTROS)
    sys.exit(1)
" || {
  echo '(If you think your OS was improperly detected, comment out "exit 1" after the OS check)'
  exit 1
}

pkgMgr=$(basename $(which apt-get || which yum || true))

if [ "apt-get" = "$pkgMgr" ] ; then
  repoType="deb"
elif [ "yum" = "$pkgMgr" ]; then
  repoType="rpm"
else
  echo "No supported package manager (apt-get or yum) detected!"
  exit 1
fi

curl=$(which curl || true)
if [ -z "$curl" ]; then
  echo "curl wasn't found. Install curl."
  exit 1
fi

# We trust packagecloud.io considering it's serving our packages anyway.

: ${INSTALLER_EXTRA_REPOS:=""}
INSTALLER_REPO="scalr-manage ${INSTALLER_EXTRA_REPOS}"

echo "Detected '$pkgMgr' -- installing '$repoType' installer repo"
for repo in $INSTALLER_REPO; do
  curl "https://packagecloud.io/install/repositories/scalr/${repo}/script.${repoType}" | sudo bash
done


# It's important to keep this around, so that if someone's install crashes the first time,
# they get another shot after we update by just re-running this script.
$pkgMgr install -y scalr-manage

# Setup remote logging
SENTRY_DSN=$(curl "https://s3.amazonaws.com/installer.scalr.com/logging/raven-dsn.txt" | tr -d '\n' || true)
if [ -n "${SENTRY_DSN}" ]; then
  echo 'Remote logging of fatal errors will be enabled -- comment out "export SENTRY_DSN" to disable it'
  echo 'NO personal information is included in remote logging -- only installer stacktraces are reported'
  export SENTRY_DSN
fi

: ${CONFIGURE_OPTIONS:=""} # Provide this in the environemnt as options for scalr-manage configure
: ${INSTALL_OPTIONS:=""} # Provide this in the environemnt as options for scalr-manage install
: ${CONFIGURATION_FILE:="/etc/scalr.json"}

# Try and do the right thing here. If there is already a configuration file laying around with the
# right version, use it. If there isn't, then create a new one (that might create an annoying prompt
# for the user to recreate their configuration, but that's a small price to pay if there was an error
# in configure and the attributes need to be fixed in an update).

if scalr-manage -c "${CONFIGURATION_FILE}" match-version; then
  echo "Already configured for '$(scalr-manage --version)', skipping configuration step"
  echo "Delete '${CONFIGURATION_FILE}' if you'd like to reconfigure"
else
  scalr-manage -c "${CONFIGURATION_FILE}" configure ${CONFIGURE_OPTIONS}
fi

scalr-manage -c "${CONFIGURATION_FILE}" subscribe
scalr-manage -c "${CONFIGURATION_FILE}" install ${INSTALL_OPTIONS}
scalr-manage -c "${CONFIGURATION_FILE}" document
