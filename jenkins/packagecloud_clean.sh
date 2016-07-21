#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for clean config
if [ -z ${PACKAGECLOUD_CLEAN+x} ]; then
  read -p "Provide full path to Packagecloud clean config file # " PACKAGECLOUD_CLEAN
fi

# Prompt user for installer branch to use if not set
if [ -z ${INSTALLER_BRANCH+x} ]; then
  read -p "Which installer branch do you want to use (leave blank for current local branch)? # " INSTALLER_BRANCH
fi

# Promt user for workspace path if not set
if [ -z ${WORKSPACE+x} ]; then
  read -p "Which path to use as workspace (leave blank for /opt/scalr-installer)? # " WORKSPACE
  if [ -z ${WORKSPACE} ]; then
    WORKSPACE="/opt/scalr-installer"
  fi
fi

# Create the environment
#source "./create_environment.sh"

# Make sure workspace exists
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

#Download the Scalr Installer
if [ ! -d "${WORKSPACE}/installer-ng" ]; then
  git clone https://github.com/Scalr/installer-ng.git
fi

#Enter Installer Dir
cd ${WORKSPACE}/installer-ng

if [ ! -z ${INSTALLER_BRANCH} ]; then
  #Fetch updates to make sure we have the latest
  git fetch

  #Move to the specified branch
  git reset --hard "origin/${INSTALLER_BRANCH}"
  #git reset --hard "${INSTALLER_BRANCH}"
fi

FILENAME=${PACKAGECLOUD_CLEAN##*/}
DIRPATH=${PACKAGECLOUD_CLEAN%/*}
DOCKER_IMG="ubuntu:trusty"

docker run \
-v ${WORKSPACE}/installer-ng:${WORKSPACE}/installer-ng \
-v ${DIRPATH}:/config \
-e CONFIG_FILE=/config/${FILENAME} \
"${DOCKER_IMG}" \
"${WORKSPACE}/installer-ng/jenkins/docker/package-cloud-cleanup/run.sh"
