#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to test # " PKG_FILE
fi

# Create the environment
source "./create_environment.sh"

FILENAME=${PKG_FILE##*/}
DIRPATH=${PKG_FILE%/*}
#DOCKER_IMG="scalr-${SCALR_OS}"

# Clear old docker container
docker rm -f "${DOCKER_IMG}-test" || true

# Create test container
DOCKER_ID=$(docker run \
-d \
--name="${DOCKER_IMG}-test" \
--tmpfs /run \
--tmpfs /run/lock \
-v /sys/fs/cgroup:/sys/fs/cgroup \
-v ${DIRPATH}:/package \
-v ${WORKSPACE}:/workspace \
-e PKG_FILE=/package/${FILENAME} \
"${DOCKER_IMG}" "/usr/sbin/init")

# Run test
docker exec ${DOCKER_ID} "/workspace/installer-ng/jenkins/docker/test_package.sh"

# Remove test container
docker rm -f "${DOCKER_IMG}-test" || true
