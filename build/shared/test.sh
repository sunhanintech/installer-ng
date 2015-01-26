#!/bin/bash
set -o errexit
set -o nounset

echo "Installing from ${PKG_FILE}"
/prepare_test.sh

echo "Configuring"
/opt/scalr-server/bin/scalr-server-ctl reconfigure
