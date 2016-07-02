#!/bin/bash
set -o nounset
set -o errexit

echo "hello"

exit 0

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to test # " PKG_FILE
fi

# Create the environment
source ./docker/create_environment.sh

FILENAME=${PKG_FILE##*/}
DIRPATH=${PKG_FILE%/*}
DOCKER_IMG="scalr-${SCALR_OS}"

docker run \
-v ${DIRPATH}:/package \
-v ${WORKSPACE}:/workspace \
-e PKG_FILE=/package/${FILENAME} \
"${DOCKER_IMG}" "/workspace/installer-ng/jenkins/docker/test_package.sh"
