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
"${DOCKER_IMG}" \
"cd ${WORKSPACE}/installer-ng/jenkins/docker/package-cloud-cleanup; pip install -r requirements.txt; python main.py /config/${FILENAME}"
