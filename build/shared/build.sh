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
  git clone --mirror "${GIT_BUNDLE_PATH}" "${GIT_CACHE_PATH}" || {
    echo "WARNING: Unable to restore! ($?)"
  }
else
  echo "No bundle to restore from (expected '${GIT_BUNDLE_PATH}')"
fi

# Cleanup old scalr-app src. This is needed because Omnibus does not properly
# remove old srcs from the cache (and our src isn't constant, because we might have
# two project workspaces in Jenkins)
rm -rf "${OMNIBUS_BASE_DIR}/src/scalr-app"

# Launch build. We handle errors manually so we disable errexit
echo "Building: ${SCALR_VERSION}"

set +o errexit
cd "${OMNIBUS_PROJECT_DIR}"
bundle install --binstubs
bin/omnibus build -l "${OMNIBUS_LOG_LEVEL}" scalr-server
ret=$?
set -o errexit

# Trim the bundle
/optimize_repo.py "${GIT_CACHE_PATH}"

# Back up the bundle
echo "Backing up '${GIT_CACHE_PATH}' to '${GIT_BUNDLE_PATH}'"
git --git-dir="${GIT_CACHE_PATH}" bundle create "${GIT_BUNDLE_PATH}" --tags

# Chown everything
cd "${OMNIBUS_PACKAGE_DIR}"
chown "${JENKINS_UID}:${JENKINS_UID}" ./*

exit ${ret}
