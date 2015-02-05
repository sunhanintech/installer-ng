#!/bin/bash
# Prepares and build the Docker image
set -o errexit
set -o pipefail
set -o nounset


##############
# Path Setup #
##############

REL_HERE=$(dirname "${BASH_SOURCE}")
ROOT=$(cd "${REL_HERE}/.."; pwd)
cd "${ROOT}"

##############
# Timestamps #
##############

build/git_fix_timestamps.sh


##########
# Target #
##########

sed -i "s/__PLATFORM_NAME__/${PLATFORM_NAME}/g" "./Dockerfile"
sed -i "s/__PLATFORM_VERSION__/${PLATFORM_VERSION}/g" "./Dockerfile"


#########
# Build #
#########

docker build -t "${DOCKER_IMG}" .
