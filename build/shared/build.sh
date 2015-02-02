#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

GIT_CACHE_PATH="${OMNIBUS_BASE_DIR}/cache/git_cache/opt/scalr-server"
GIT_BUNDLE_PATH="${OMNIBUS_PACKAGE_DIR}/git_cache.bundle"

: ${OMNIBUS_LOG_LEVEL:="info"}

# Prepare git config
git config --global user.email "builder@scalr.com"
git config --global user.name "Scalr Builder"


# Do we have a bundle to restore?
if [ -f "${GIT_BUNDLE_PATH}" ]; then
  echo "Restoring '${GIT_BUNDLE_PATH}' to '${GIT_CACHE_PATH}'"

  # Remove anything that might have existed before.
  mkdir --parents "${GIT_CACHE_PATH}"
  rm -rf "${GIT_CACHE_PATH}"
  git clone --mirror "${GIT_BUNDLE_PATH}" "${GIT_CACHE_PATH}"
else
  echo "No bundle to restore from (expected '${GIT_BUNDLE_PATH}')"
fi


# Launch build. We handle errors manually so we disable errexit
echo "Building: ${SCALR_VERSION}"

set +o errexit
cd /builder
bin/omnibus build -l "${OMNIBUS_LOG_LEVEL}" scalr-server
ret=$?
set -o errexit

# Trim the bundle
build/shared/optimize_repo.py "${GIT_CACHE_PATH}"

# Back up the bundle
echo "Backing up '${GIT_CACHE_PATH}' to '${GIT_BUNDLE_PATH}'"
git --git-dir="${GIT_CACHE_PATH}" bundle create "${GIT_BUNDLE_PATH}" --tags

# Chown everything
cd "${OMNIBUS_PACKAGE_DIR}"
chown "${JENKINS_UID}:${JENKINS_UID}" *

exit ${ret}
