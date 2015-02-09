#!/bin/bash
set -o nounset
set -o errexit

# Where are we?
REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)

# Try and guess Scalr dir
if [ "$(git rev-parse --abbrev-ref HEAD)" = "omnibus-package.oss" ]; then
  repo_name="scalr"
else
  repo_name="int-scalr"
fi
scalr_candidate="${HERE}/../../../${repo_name}"

if [ -d "${scalr_candidate}" ]; then
  echo "It looks like you have a clone of Scalr in:"
  echo "${scalr_candidate}"
else
  scalr_candidate=""
fi

# Config
: ${DOCKER_PREFIX:="test-scalr"}
: ${TEST_IMG:="scalr-server"}
: ${SCALR_DIR:="${scalr_candidate}"}
CLUSTER_LIFE="172800"


# Prepare shared config
COOKBOOK_DIR="${HERE}/../../files/scalr-server-cookbooks/scalr-server"

runArgs=(
  "-t" "-d"
  "-v" "${COOKBOOK_DIR}:/opt/scalr-server/embedded/cookbooks/scalr-server"
)

if [ -n "$SCALR_DIR" ]; then
  # Mount app and sql separately to not blow away the manifest.
  runArgs+=(
    "-v" "${SCALR_DIR}/app:/opt/scalr-server/embedded/scalr/app"
    "-v" "${SCALR_DIR}/sql:/opt/scalr-server/embedded/scalr/sql"
  )
fi

imgArgs=("${TEST_IMG}" "sleep" "${CLUSTER_LIFE}")

# Prepare cluster config

CONF_FILE="${HERE}/scalr-server.rb"
SECRETS_FILE="${HERE}/scalr-server-secrets.json"

LOCAL_DB_FILE="${HERE}/scalr-server-local.db.rb"
LOCAL_APP_FILE="${HERE}/scalr-server-local.app.rb"

clusterArgs=(
  "-v" "${CONF_FILE}:/etc/scalr-server/scalr-server.rb"
  "-v" "${SECRETS_FILE}:/etc/scalr-server/scalr-server-secrets.json"
)
dbArgs=("-v" "${LOCAL_DB_FILE}:/etc/scalr-server/scalr-server-local.rb")
appArgs=(
  "-v" "${LOCAL_APP_FILE}:/etc/scalr-server/scalr-server-local.rb"
  "--link=${DOCKER_PREFIX}-db:db" "--link=${DOCKER_PREFIX}-ca:ca"
  "--publish-all"
)


# Remove all old hosts
docker rm -f "${DOCKER_PREFIX}"-{db,ca,app,solo} || true


# First, multi-host test

docker run "${runArgs[@]}" "${clusterArgs[@]}" "${dbArgs[@]}"  --name="${DOCKER_PREFIX}-db"  "${imgArgs[@]}"
docker run "${runArgs[@]}" "${clusterArgs[@]}" "${dbArgs[@]}"  --name="${DOCKER_PREFIX}-ca"  "${imgArgs[@]}"
docker run "${runArgs[@]}" "${clusterArgs[@]}" "${appArgs[@]}" --name="${DOCKER_PREFIX}-app" "${imgArgs[@]}"

docker exec -it "${DOCKER_PREFIX}-db" scalr-server-ctl reconfigure
docker exec -it "${DOCKER_PREFIX}-ca" scalr-server-ctl reconfigure
docker exec -it "${DOCKER_PREFIX}-app" scalr-server-ctl reconfigure

docker rm -f "${DOCKER_PREFIX}"-{db,ca,app}


# Second, single host test. This has a more complex command sequence since we're actually exercising the
# installer.

soloCmds=(
  "scalr-server-ctl reconfigure"
  "service scalr status"
  "service scalr stop"
  "sleep 10"
  "scalr-server-ctl reconfigure"
  "service scalr status"
)

docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-solo" --publish-all "${imgArgs[@]}"

for cmd in "${soloCmds[@]}"; do
  docker exec -it "${DOCKER_PREFIX}-solo" $cmd
done

docker rm -f "${DOCKER_PREFIX}-solo"

# Finally, cleanup everything
