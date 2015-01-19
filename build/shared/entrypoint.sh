#!/bin/bash
echo "Preparing rvm"
source /usr/local/rvm/scripts/rvm

set -o errexit
set -o nounset

echo "Preparing package cloud settings"
echo "${PACKAGE_CLOUD_SETTINGS}" > "${BUILD_HOME}/.packagecloud"

echo "Executing $@"
exec "$@"
