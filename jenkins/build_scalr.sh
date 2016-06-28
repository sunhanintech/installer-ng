#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for version if not set
if [ -z ${SCALR_VERSION+x} ]; then
  while true; do
    echo "1) Enterprise"
    echo "2) Open Source"
    read -p "Which version do you want to build? # " option
    case $option in
      [1]* ) SCALR_VERSION="Enterprise"; break;;
      [2]* ) SCALR_VERSION="OpenSource"; break;;
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

# Prompt user for scalr branch to use if not set
if [ -z ${SCALR_BRANCH+x} ]; then
  read -p "Which Scalr branch do you want to use (leave blank for current local branch)? # " SCALR_BRANCH
fi

# Install needed tools
command -v git >/dev/null 2>&1 || apt-get install -y git
command -v docker >/dev/null 2>&1 || apt-get install -y docker.io

# Set repo variables
if [ "${SCALR_VERSION}" = "Enterprise" ]; then
  SCALR_REPO="int-scalr"
  EDITION="enterprise"
else
  SCALR_REPO="scalr"
  EDITION="opensource"
fi

# Set platform variables
IFS=- read PLATFORM_NAME PLATFORM_VERSION <<< ${SCALR_OS}

# Set standard platform names
if [[ "centos" = "${PLATFORM_NAME}" ]]; then
  #PLATFORM_NAME="el"
  PLATFORM_FAMILY="rhel"
  PACKAGE_NAME="${EDITION}"
elif [[ "debian" = "${PLATFORM_NAME}" ]] || [[ "ubuntu" = "${PLATFORM_NAME}" ]]; then
  PLATFORM_FAMILY="debian"
  PACKAGE_NAME="${EDITION}.${PLATFORM_VERSION}"
else
  echo "Unknown platform: ${PLATFORM_NAME}"
fi

SENTRY="https://e3d78868da8f468a9d69c0e6091e4caf:18b65fdb4ac44ddaa854e037c68ceda1@app.getsentry.com/34322"
WORKDIR="/mnt/scalr-installer"
DOCKER_IMG="scalr-${PLATFORM_NAME}-${PLATFORM_VERSION}"
CONTAINER="${DOCKER_IMG}-${EDITION}"

# Make sure workdir exists
mkdir -p ${WORKDIR}
cd ${WORKDIR}

#Force close current running jobs
if docker ps | grep " ${CONTAINER} "; then
  docker rm -f "${CONTAINER}"
fi

#Create needed dirs
#mkdir -p ${WORKDIR}/scratch
mkdir -p ${WORKDIR}/build
mkdir -p ${WORKDIR}/shared

#Download the Scalr Installer
if [ ! -d "${WORKDIR}/installer-ng" ]; then
  git clone https://github.com/Scalr/installer-ng.git
fi

#Enter Installer Dir
cd ${WORKDIR}/installer-ng

if [ ! -z ${INSTALLER_BRANCH} ]; then
  #Fetch updates to make sure we have the latest
  git fetch

  #Move to the specified branch
  git reset --hard "origin/${INSTALLER_BRANCH}"
  #git reset --hard "${INSTALLER_BRANCH}"
fi

#Read the installer revision
INSTALLER_REVISION=$(git log -n 1 --date="local" --pretty=format:"%h")

#Set platform variables
sed "s/{PLATFORM_NAME}/${PLATFORM_NAME}/g" ./jenkins/docker/Dockerfile.in > ./Dockerfile
sed -i "s/{PLATFORM_FAMILY}/${PLATFORM_FAMILY}/g" ./Dockerfile
sed -i "s/{PLATFORM_VERSION}/${PLATFORM_VERSION}/g" ./Dockerfile

#Create the build image if not exist
if [[ "$(docker images -q "${DOCKER_IMG}" 2> /dev/null)" == "" ]]; then
  docker build -t "${DOCKER_IMG}" .
fi

#exit 0

#Go to workdir
cd ${WORKDIR}

#Download the Scalr source code
if [ ! -d "${WORKDIR}/${SCALR_REPO}" ]; then
  if [ "${SCALR_REPO}" = "scalr" ]; then
    git clone "https://github.com/Scalr/${SCALR_REPO}.git"
  else
    ssh-keyscan github.com >> ~/.ssh/known_hosts
    git clone "git@github.com:Scalr/${SCALR_REPO}.git"
  fi
fi

#Enter Scalr directory
cd ${WORKDIR}/${SCALR_REPO}

if [ ! -z ${SCALR_BRANCH} ]; then
  #Fetch updates to make sure we have the latest
  git fetch

  #Move to the specified branch
  git reset --hard "origin/${SCALR_BRANCH}"
fi

#Read data from Scalr source code
SCALR_VERSION=$(cat ./app/etc/version)
SCALR_REVISION=$(git log -n 1 --date="local" --pretty=format:"%h")
SCALR_REVISION_FULL=$(git log -n 1 --date="local" --pretty=format:"%H")
SCALR_DATE=$(git log -n 1 --date="local" --pretty=format:"%cD")

#Enter Installer Dir
cd ${WORKDIR}/installer-ng

#Replace values in Scalr source code
sed -i "s|__SCALR_APP_PATH__|${WORKDIR}/${SCALR_REPO}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_REVISION__|${SCALR_REVISION}|g" "./config/software/scalr-app.rb"

sed -i "s|__SCALR_APP_EDITION__|${EDITION}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_DATE__|${SCALR_DATE}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_FULL_REVISION__|${SCALR_REVISION_FULL}|g" "./config/software/scalr-app.rb"

sed -i "s|__SCALR_REQUIREMENTS_PATH__|${WORKDIR}/${SCALR_REPO}/app/python|g" "./config/software/scalr-app-python-libs.rb"

sed -i "s|__SENTRY_DSN__|${SENTRY}|g" "./files/scalr-server-cookbooks/dna.json"
sed -i "s|__SENTRY_DSN__|${SENTRY}|g" "./files/scalr-server-cookbooks/extras.json"

sed -i "s|__INSTALLER_REVISION__|${INSTALLER_REVISION}|g" "./config/software/scalr-server-cookbooks.rb"
sed -i "s|__INSTALLER_REVISION__|${INSTALLER_REVISION}|g" "./config/software/scalr-server-bin.rb"

#This one seems to kill the cache :(
#sed -i "s|build_iteration 1|build_iteration ${BUILD_NUMBER}|g" "./config/projects/scalr-server.rb"

#Compile the Scalr package
docker run --rm --name="${CONTAINER}" \
-v ${WORKDIR}/installer-ng:${WORKDIR}/installer-ng \
-v ${WORKDIR}/shared/${PLATFORM_NAME}/${PLATFORM_VERSION}/${EDITION}:${WORKDIR}/shared/${PLATFORM_NAME}/${PLATFORM_VERSION}/${EDITION} \
-v ${WORKDIR}/build:${WORKDIR}/build \
-v ${WORKDIR}/${SCALR_REPO}:${WORKDIR}/${SCALR_REPO} \
-e OMNIBUS_BASE_DIR=${WORKDIR}/shared/${PLATFORM_NAME}/${PLATFORM_VERSION}/${EDITION} \
-e OMNIBUS_PACKAGE_DIR=${WORKDIR}/build \
-e OMNIBUS_LOG_LEVEL=info \
-e OMNIBUS_NO_BUNDLE=0 \
-e OMNIBUS_PROJECT_DIR=${WORKDIR}/installer-ng \
-e SCALR_VERSION="${SCALR_VERSION}.${PACKAGE_NAME}" \
-e JENKINS_UID=root \
"${DOCKER_IMG}" "/omnibus_build.sh"

#Generate package filename
if [[ "centos" = "${PLATFORM_NAME}" ]]; then
  PKG_FILE="scalr-server_${SCALR_VERSION}.${EDITION}.x86_64.rpm"
elif [[ "debian" = "${PLATFORM_NAME}" ]] || [[ "ubuntu" = "${PLATFORM_NAME}" ]]; then
  PKG_FILE="scalr-server_${SCALR_VERSION}.${EDITION}-1_amd64.deb"
fi

