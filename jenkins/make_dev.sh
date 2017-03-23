#!/bin/bash
set -o nounset
set -o errexit

# Promt user for workspace path if not set
if [ -z ${WORKSPACE+x} ]; then
  read -p "Which path to use as workspace (leave blank for /opt/scalr-installer)? # " WORKSPACE
  if [ -z ${WORKSPACE} ]; then
    WORKSPACE="/opt/scalr-installer"
  fi
fi

if [ -z ${GITHUB_SECRET+x} ]; then
  read -p "Enter the path to SSH key to use for git (leave empty for /root/.ssh/id_rsa)? # " GITHUB_SECRET
  if [ -z ${GITHUB_SECRET} ]; then
    GITHUB_SECRET="/root/.ssh/id_rsa"
  fi
fi

# Prompt user for scalr branch to use if not set
if [ -z ${SCALR_BRANCH+x} ]; then
  read -p "Which Scalr branch do you want to use (leave blank for master)? # " SCALR_BRANCH
  if [ -z ${SCALR_BRANCH} ]; then
    SCALR_BRANCH="master"
  fi
fi

# Prompt user for cryptokey
if [ -z ${CRYPTO_KEY+x} ]; then
  read -p "Enter the path to the crypto key file to use (leave blank for /opt/scalr-installer/cryptokey)? # " CRYPTO_KEY
  if [ -z ${CRYPTO_KEY} ]; then
    CRYPTO_KEY="/opt/scalr-installer/cryptokey"
  fi
fi

if [ -z ${TEST_CONFIG+x} ]; then
  read -p "Enter the path to scalr-server.rb to use (leave empty for /opt/scalr-installer/scalr-server.rb)? # " TEST_CONFIG
  if [ -z ${TEST_CONFIG} ]; then
    TEST_CONFIG="/opt/scalr-installer/scalr-server.rb"
  fi
fi

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to use # " PKG_FILE
fi

# Make sure workspace exists
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

#Download the infrastructure-scripts
if [ ! -d "${WORKSPACE}/infrastructure-scripts" ]; then
  git clone "ext::ssh -o StrictHostKeyChecking=no -i ${GITHUB_SECRET} git@github.com %S /Scalr/infrastructure-scripts.git"
fi

#Enter infrastructure Dir
cd ${WORKSPACE}/infrastructure-scripts

#Make sure we are on latest version
git fetch --all
git reset --hard origin/master

cd ${WORKSPACE}/infrastructure-scripts/testenv/testenv_docker

sed -i '/Install scalr package/,/Configure Scalr install/{//!d}' Dockerfile
sed -i "/Install scalr package/a ADD scalr.deb /scalr.deb\nRUN dpkg -i /scalr.deb" Dockerfile

cp ${GITHUB_SECRET} ./additions/root/.ssh/scalr
cp ${CRYPTO_KEY} ./.cryptokey
cp ${PKG_FILE} ./scalr.deb
cp ${TEST_CONFIG} ./scalr-server.rb

IMAGE_TAG="${SCALR_BRANCH}"
if [ "${IMAGE_TAG}" = "master" ]; then
  IMAGE_TAG="${INSTALLER_BRANCH}"
fi

IMAGE_TAG=$(echo "${IMAGE_TAG}" | awk '{print tolower($0)}' | sed -e 's/[^a-z0-9]/-/g')
IMAGE_TAG="gcr.io/scalr-labs/scalr/${SCALR_BRANCH_TAG}/scalr-container:latest"

TEMP_IMAGE="scalr-dev-engineering"
IMAGE_ID=$(docker images | grep -E "^${TEMP_IMAGE}" | awk -e '{print $3}')

#Delete existing container
docker rmi -f "${IMAGE_ID}" || true

#Build image
docker build -t "${TEMP_IMAGE}" .

#Tag the image
docker tag "${TEMP_IMAGE}" "${IMAGE_TAG}"

#Upload the image
gcloud docker -- push "${IMAGE_TAG}"

#Delete the image
IMAGE_ID=$(docker images | grep -E "^${TEMP_IMAGE}" | awk -e '{print $3}')
docker rmi -f "${IMAGE_ID}" || true
