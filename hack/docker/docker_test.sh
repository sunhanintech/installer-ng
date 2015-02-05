#!/bin/bash
set -o nounset
set -o errexit

# Config
: ${DOCKER_PREFIX:="test-scalr"}
: ${TEST_IMG:="scalr-server"}
CLUSTER_LIFE="172800"

# Start here

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)

# Prepare shared config
COOKBOOK_DIR="${HERE}/../../files/scalr-server-cookbooks/scalr-server"

runArgs=(
  "-t" "-d"
  "-v" "${COOKBOOK_DIR}:/opt/scalr-server/embedded/cookbooks/scalr-server"
  "--publish-all"
)

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

docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-solo" "${imgArgs[@]}"

for cmd in "${soloCmds[@]}"; do
  docker exec -it "${DOCKER_PREFIX}-solo" $cmd
done

docker rm -f "${DOCKER_PREFIX}-solo"

# Finally, cleanup everything
