#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for clean config
if [ -z ${PACKAGECLOUD_CLEAN+x} ]; then
  read -p "Provide full path to Packagecloud clean config file # " PACKAGECLOUD_CLEAN
fi

# Create the environment
source "./docker/create_environment.sh"

FILENAME=${PACKAGECLOUD_CLEAN##*/}
DIRPATH=${PACKAGECLOUD_CLEAN%/*}

docker run \
-v ${WORKSPACE}/installer-ng:${WORKSPACE}/installer-ng \
-v ${DIRPATH}:/config \
-e CONFIG_FILE=/package/${FILENAME} \
"${DOCKER_IMG}" \
"${WORKSPACE}/installer-ng/jenkins/docker/package-cloud-cleanup/run.sh"
