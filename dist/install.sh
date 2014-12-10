#!/bin/sh
set -o errexit
set -o nounset

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
echo "Detected '$pkgMgr' -- installing '$repoType' installer repo"
curl "https://packagecloud.io/install/repositories/scalr/scalr-manage/script.${repoType}" | sudo bash

$pkgMgr install -y scalr-manage

# Setup remote logging
SENTRY_DSN=$(curl "https://s3.amazonaws.com/installer.scalr.com/logging/raven-dsn.txt" | tr -d '\n' || true)
if [ -n "${SENTRY_DSN}" ]; then
  echo 'Remote logging of fatal errors will be enabled -- comment out "export SENTRY_DSN" to disable it'
  echo 'NO personal information is included in remote logging -- only installer stacktraces are reported'
  export SENTRY_DSN
fi

CONFIGURATION_FILE="/etc/scalr.json"

if [ -f "${CONFIGURATION_FILE}" ]; then
  echo "Already configured -- skipping configuration step"
  echo "Delete '${CONFIGURATION_FILE}' if you'd like to reconfigure"
else
  scalr-manage -c "${CONFIGURATION_FILE}" configure
fi

scalr-manage -c "${CONFIGURATION_FILE}" subscribe
scalr-manage -c "${CONFIGURATION_FILE}" install
scalr-manage -c "${CONFIGURATION_FILE}" document
