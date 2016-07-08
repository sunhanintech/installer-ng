#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to upload # " PKG_FILE
fi

# Prompt user for packagecloud repo to use
if [ -z ${PACKAGECLOUD_REPO+x} ]; then
  read -p "Enter which Packagecloud repo to use # " PACKAGECLOUD_REPO
fi

# Prompt user for packagecloud token to use
if [ -z ${PACKAGECLOUD_TOKEN+x} ]; then
  read -p "Enter Packagecloud token to use # " PACKAGECLOUD_TOKEN
fi

# Create the environment
source "./docker/create_environment.sh"

FILENAME=${PKG_FILE##*/}
DIRPATH=${PKG_FILE%/*}
DOCKER_IMG="scalr-${SCALR_OS}"

# If this is centos, also upload oracle versions
#if PLATFORM=el/6, replace el with ol

docker run \
-v ${DIRPATH}:/package \
-e "PACKAGECLOUD_TOKEN=${PACKAGECLOUD_TOKEN}" \
"${DOCKER_IMG}" \
package_cloud push \
"${PACKAGECLOUD_REPO}/${PLATFORM}/${PLATFORM_VERSION}" \
"/package/${FILENAME}"
