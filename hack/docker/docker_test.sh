#!/bin/bash
set -o errexit

# Options processing

FAST=0
KEEP=0

while true; do
  if [ "${1}" = "fast" ]; then
    FAST=1
  elif [ "${1}" = "keep" ]; then
    KEEP=1
  elif [ -z "${1}" ]; then
    break
  else
    echo "Unknown option: ${1}"
  fi
  shift
done

echo "FAST: $FAST"
echo "KEEP: $KEEP"
echo "DOCKER_HOST: ${DOCKER_HOST}"

set -o nounset

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

LOCAL_APP_FILE="${HERE}/scalr-server-local.app.rb"
LOCAL_DB_FILE="${HERE}/scalr-server-local.db.rb"
LOCAL_PROXY_FILE="${HERE}/scalr-server-local.proxy.rb"
LOCAL_STATS_FILE="${HERE}/scalr-server-local.stats.rb"
LOCAL_WORKER_FILE="${HERE}/scalr-server-local.worker.rb"

clusterArgs=(
  "-v" "${CONF_FILE}:/etc/scalr-server/scalr-server.rb"
  "-v" "${SECRETS_FILE}:/etc/scalr-server/scalr-server-secrets.json"
)

clientArgs=(
  "--link=${DOCKER_PREFIX}-db:db"
  "--link=${DOCKER_PREFIX}-ca:ca"
)

dbArgs=("-v" "${LOCAL_DB_FILE}:/etc/scalr-server/scalr-server-local.rb")
appArgs=("-v" "${LOCAL_APP_FILE}:/etc/scalr-server/scalr-server-local.rb")
statsArgs=("-v" "${LOCAL_STATS_FILE}:/etc/scalr-server/scalr-server-local.rb")
workerArgs=("-v" "${LOCAL_WORKER_FILE}:/etc/scalr-server/scalr-server-local.rb")
proxyArgs=(
  "-v" "${LOCAL_PROXY_FILE}:/etc/scalr-server/scalr-server-local.rb"
  "--link=${DOCKER_PREFIX}-app-1:app-1"
  "--link=${DOCKER_PREFIX}-app-2:app-2"
  "--link=${DOCKER_PREFIX}-stats:stats"
  "--publish-all"
)

tierNames=("db" "ca" "app-1" "app-2" "stats" "worker" "proxy")


if [ "${FAST}" -eq 0 ]; then
  # Remove all old hosts
  for tier in "${tierNames[@]}"; do
    docker rm -f "${DOCKER_PREFIX}-$tier" || true
  done

  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${dbArgs[@]}"  --name="${DOCKER_PREFIX}-db"  "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${dbArgs[@]}"  --name="${DOCKER_PREFIX}-ca"  "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${clientArgs[@]}" "${appArgs[@]}" --name="${DOCKER_PREFIX}-app-1" "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${clientArgs[@]}" "${appArgs[@]}" --name="${DOCKER_PREFIX}-app-2" "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${clientArgs[@]}" "${statsArgs[@]}" --name="${DOCKER_PREFIX}-stats" "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${clientArgs[@]}" "${workerArgs[@]}" --name="${DOCKER_PREFIX}-worker" "${imgArgs[@]}"
  docker run "${runArgs[@]}" "${clusterArgs[@]}" "${clientArgs[@]}" "${proxyArgs[@]}" --name="${DOCKER_PREFIX}-proxy" "${imgArgs[@]}"

  for tier in "${tierNames[@]}"; do
    docker exec -it "${DOCKER_PREFIX}-${tier}" scalr-server-ctl reconfigure
  done

  # TODO - Test app!
  if [ "${KEEP}" -eq 0 ]; then
    for tier in "${tierNames[@]}"; do
      docker rm -f "${DOCKER_PREFIX}-$tier" || true
    done
  fi
fi


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

# Cleanup old box
docker rm -f "${DOCKER_PREFIX}-solo" || true

docker run "${runArgs[@]}" --name="${DOCKER_PREFIX}-solo" --publish-all "${imgArgs[@]}"

for cmd in "${soloCmds[@]}"; do
  docker exec -it "${DOCKER_PREFIX}-solo" $cmd
done

if [ "${KEEP}" -eq 0 ]; then
  docker rm -f "${DOCKER_PREFIX}-solo"
fi
