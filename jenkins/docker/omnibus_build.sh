#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

: ${OMNIBUS_NO_BUNDLE:="0"}
: ${OMNIBUS_LOG_LEVEL:="info"}

# Prepare git config
git config --global user.email "builder@scalr.com"
git config --global user.name "Scalr Builder"

# Cleanup old scalr-app src. This is needed because Omnibus does not properly
# remove old srcs from the cache (and our src isn't constant, because we might have
# two project workspaces in Jenkins)
rm -rf "${OMNIBUS_BASE_DIR}/src/scalr-app"

# Before we do anything. Setup a trap to chown everything back to Jenkins' user.
cleanup () {
  cd "${OMNIBUS_PROJECT_DIR}"
  rm -rf ./pkg/*  # For some reason, a duplicate of every package ends up there.
  chown -R "${JENKINS_UID}" .
  #chown -R "${JENKINS_UID}" /mnt/cache
}

trap cleanup EXIT

# Launch build. We handle errors manually so we disable errexit
echo "Building: ${SCALR_VERSION}"

cd "${OMNIBUS_PROJECT_DIR}"
bundle install

set +o errexit
bundle exec omnibus build -l "${OMNIBUS_LOG_LEVEL}" "scalr-server"
ret=$?
set -o errexit

exit ${ret}

