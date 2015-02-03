#!/bin/bash
set -o nounset
set -o errexit

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)

COOKBOOK_DIR="${HERE}/../../files/scalr-server-cookbooks/scalr-server"

CONF_FILE="${HERE}/scalr-server.rb"
LOCAL_DB_FILE="${HERE}/scalr-server-local.db.rb"
LOCAL_APP_FILE="${HERE}/scalr-server-local.app.rb"
SECRETS_FILE="${HERE}/scalr-server-secrets.json"

runArgs=("-t" "-d"
  "-v" "${COOKBOOK_DIR}:/opt/scalr-server/embedded/cookbooks/scalr-server"
  "-v" "${CONF_FILE}:/etc/scalr-server/scalr-server.rb"
  "-v" "${SECRETS_FILE}:/etc/scalr-server/scalr-server-secrets.json"
  "--publish-all"
)

IMG="scalr-server"
CLUSTER_LIFE="172800"
imgArgs=("${IMG}" "sleep" "${CLUSTER_LIFE}")

: ${DOCKER_PREFIX:="test-scalr"}

DB_LOCAL_MOUNT="${LOCAL_DB_FILE}:/etc/scalr-server/scalr-server-local.rb"
APP_LOCAL_MOUNT="${LOCAL_APP_FILE}:/etc/scalr-server/scalr-server-local.rb"

docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-db" -v "${DB_LOCAL_MOUNT}" "${imgArgs[@]}"
docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-ca" -v "${DB_LOCAL_MOUNT}" "${imgArgs[@]}"
docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-app" --link="${DOCKER_PREFIX}-db:db" --link="${DOCKER_PREFIX}-ca:ca" -v "${APP_LOCAL_MOUNT}" "${imgArgs[@]}"

echo "Launched!"

docker exec -it "${DOCKER_PREFIX}-db" scalr-server-ctl reconfigure
docker exec -it "${DOCKER_PREFIX}-ca" scalr-server-ctl reconfigure
docker exec -it "${DOCKER_PREFIX}-app" scalr-server-ctl reconfigure

docker rm -f "${DOCKER_PREFIX}-db" "${DOCKER_PREFIX}-ca" "${DOCKER_PREFIX}-app"
