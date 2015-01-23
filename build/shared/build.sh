#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

git config --global user.email "builder@scalr.com"
git config --global user.name "Scalr Builder"

# Prepare the build
cd /builder

# Launch build
echo "Building: ${SCALR_VERSION}"
bin/omnibus build scalr-server

cd "${OMNIBUS_PACKAGE_DIR}"
chown "${JENKINS_UID}:${JENKINS_UID}" *

