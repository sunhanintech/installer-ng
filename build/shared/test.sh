#!/bin/bash
set -o errexit
set -o nounset

echo "Installing from ${PKG_FILE}"
/prepare_test.sh

echo "Testing wizard"
/opt/scalr-server/bin/scalr-server-wizard

echo "Configuring"
/opt/scalr-server/bin/scalr-server-ctl reconfigure
