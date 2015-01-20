#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# Where are we?
REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)
COOKBOOKS_PATH=$(cd "${HERE}/../files/scalr-server-cookbooks/"; pwd)

# This repo is cloned
PROFILE_FILE="/etc/profile.d/scalr_installer_dev_env.sh"
touch "${PROFILE_FILE}"
chmod 644 "${PROFILE_FILE}"
echo "export SCALR_COOKBOOK_EXTRA_SEARCH_PATH=\"${COOKBOOKS_PATH}\"" > "${PROFILE_FILE}"

# Notify the user
echo "You should now run:"
echo "    source \"${PROFILE_FILE}\""
echo "You won't need to run this next time you login"
