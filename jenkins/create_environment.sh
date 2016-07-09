#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for version if not set
if [ -z ${EDITION+x} ]; then
  while true; do
    echo "1) Enterprise"
    echo "2) Open Source"
    read -p "Which version do you want to build? # " option
    case $option in
      [1]* ) EDITION="enterprise"; break;;
      [2]* ) EDITION="opensource"; break;;
    esac
  done
fi

# Prompt user for linux distribution if not set
if [ -z ${SCALR_OS+x} ]; then
  while true; do
    echo "1) ubuntu-precise"
    echo "2) ubuntu-trusty"
    echo "3) debian-wheezy"
    echo "4) debian-jessie"
    echo "5) centos-6"
    echo "6) centos-7"
    read -p "Which Linux distribution do you want to build for? # " option
    case $option in
      [1]* ) SCALR_OS="ubuntu-precise"; break;;
      [2]* ) SCALR_OS="ubuntu-trusty"; break;;
      [3]* ) SCALR_OS="debian-wheezy"; break;;
      [4]* ) SCALR_OS="debian-jessie"; break;;
      [5]* ) SCALR_OS="centos-6"; break;;
      [6]* ) SCALR_OS="centos-7"; break;;
    esac
  done
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

# Prompt user if containers should be cleaned
if [ -z ${CLEAN_ENVIRONMENT+x} ]; then
  read -p "Should the build containers be deleted and rebuilt (leave empty for No)? # " CLEAN_ENVIRONMENT
  if [ -z ${CLEAN_ENVIRONMENT} ]; then
    CLEAN_ENVIRONMENT="No"
  fi
fi

# Install needed tools
command -v git >/dev/null 2>&1 || apt-get install -y git
command -v docker >/dev/null 2>&1 || apt-get install -y docker.io

# Set repo variables
if [ "${EDITION}" = "enterprise" ]; then
  SCALR_REPO="int-scalr"
else
  SCALR_REPO="scalr"
fi

# Set platform variables
IFS=- read PLATFORM_NAME PLATFORM_VERSION <<< ${SCALR_OS}

# Set standard platform names
if [[ "centos" = "${PLATFORM_NAME}" ]]; then
  PLATFORM="el"
  PLATFORM_FAMILY="rhel"
  PACKAGE_NAME="${EDITION}"
elif [[ "debian" = "${PLATFORM_NAME}" ]] || [[ "ubuntu" = "${PLATFORM_NAME}" ]]; then
  PLATFORM="${PLATFORM_NAME}"
  PLATFORM_FAMILY="debian"
  PACKAGE_NAME="${EDITION}.${PLATFORM_VERSION}"
else
  echo "Unknown platform: ${PLATFORM_NAME}"
fi

DOCKER_IMG="scalr-${PLATFORM_NAME}-${PLATFORM_VERSION}"
CONTAINER="${DOCKER_IMG}-${EDITION}"

# Make sure workspace exists
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

#Force close current running jobs
if docker ps --all | grep " ${CONTAINER} "; then
  docker rm -f "${CONTAINER}"
fi

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

#Set platform variables
sed "s/{PLATFORM_NAME}/${PLATFORM_NAME}/g" ./jenkins/docker/Dockerfile.in > ./Dockerfile
sed -i "s/{PLATFORM_FAMILY}/${PLATFORM_FAMILY}/g" ./Dockerfile
sed -i "s/{PLATFORM_VERSION}/${PLATFORM_VERSION}/g" ./Dockerfile

# Remove existing containers
if [[ "Yes" = "${CLEAN_ENVIRONMENT}" ]]; then
  docker rmi -f "${DOCKER_IMG}"
fi

#Create the build image if not exist
if [[ "$(docker images -q "${DOCKER_IMG}" 2> /dev/null)" == "" ]]; then
  docker build -t "${DOCKER_IMG}" .
fi

