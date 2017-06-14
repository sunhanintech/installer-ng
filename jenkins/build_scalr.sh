#!/bin/bash
set -o nounset
set -o errexit

# Create the environment
source  "./create_environment.sh"

# Prompt user for scalr branch to use if not set
if [ -z ${SCALR_BRANCH+x} ]; then
  read -p "Which Scalr branch do you want to use (leave blank for current local branch)? # " SCALR_BRANCH
fi

# Promt user for cache path if not set
if [ -z ${CACHE_PATH+x} ]; then
  read -p "Which path to use for cache (leave blank for /opt/scalr-installer/cache)? # " CACHE_PATH
  if [ -z ${CACHE_PATH} ]; then
    CACHE_PATH="${WORKSPACE}/cache"
  fi
fi

# Prompt user if cache should be cleaned
if [ -z ${CLEAN_CACHE+x} ]; then
  read -p "Should the cache be cleaned (leave empty for No)? # " CLEAN_CACHE
  if [ -z ${CLEAN_CACHE} ]; then
    CLEAN_CACHE="No"
  fi
fi

# Prompt user for github ssh key
EDITION_SHORT="oss"
if [ "${EDITION}" = "enterprise" ]; then
  EDITION_SHORT="ee"
  if [ -z ${GITHUB_SECRET+x} ]; then
    read -p "Enter the path to SSH key to use for git (leave empty for ~/.ssh/id_rsa)? # " GITHUB_SECRET
    if [ -z ${GITHUB_SECRET} ]; then
      GITHUB_SECRET="~/.ssh/id_rsa"
    fi
  fi
fi

#Create needed dirs
mkdir -p ${WORKSPACE}/package

FULL_CACHE_DIR="${CACHE_PATH}/${PLATFORM_NAME}/${PLATFORM_VERSION}/${EDITION}"

if [[ "${CLEAN_CACHE}" = "Yes" ]]; then
  rm -fr "${WORKSPACE}/package/git_cache.bundle"
  rm -fr "${FULL_CACHE_DIR}/cache/git_cache"
fi

#Download the Scalr Installer
if [ ! -d "${WORKSPACE}/installer-ng" ]; then
  git clone --recursive https://github.com/Scalr/installer-ng.git
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

#Read the installer revision
INSTALLER_REVISION=$(git log -n 1 --date="local" --pretty=format:"%h")

# Make sure workspace exists
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

#Download the Scalr source code
if [ ! -d "${WORKSPACE}/${SCALR_REPO}" ]; then
  if [ "${SCALR_REPO}" = "scalr" ]; then
    git clone "https://github.com/Scalr/${SCALR_REPO}.git"
  else
    cat > ~/.ssh/config <<EOL
host github.com
 HostName github.com
 IdentityFile ${GITHUB_SECRET}
 User git
 StrictHostKeyChecking no
 UserKnownHostsFile=/dev/null
EOL

    git clone git@github.com:Scalr/${SCALR_REPO}.git
  fi
fi

#Enter Scalr directory
cd ${WORKSPACE}/${SCALR_REPO}

if [ ! -z ${SCALR_BRANCH} ]; then
  #Fetch updates to make sure we have the latest
  git fetch

  #Move to the specified branch
  git reset --hard "origin/${SCALR_BRANCH}"

  #Update submodules
  git submodule update --init --recursive

  #Fetch python requirements file
  cp ./app/python/fatmouse/infra/requirements/server-all.txt ./app/python/
  cp ./app/python/fatmouse/infra/requirements/scalrpy.txt ./app/python/

  #Delete files that should not be in the package
  if [ -f '.releaseignore' ]; then
    cat .releaseignore | while read file; do

      if [ -f ".$file" ]; then
          rm ".$file"
      elif [ -d ".$file" ]; then
          rm -fr ".$file"
      fi

    done
  fi

fi

#Read data from Scalr source code
SCALR_VERSION=$(cat ./app/etc/version)
SCALR_REVISION=$(git log -n 1 --date="local" --pretty=format:"%h")
SCALR_REVISION_FULL=$(git log -n 1 --date="local" --pretty=format:"%H")
SCALR_DATE=$(git log -n 1 --date="local" --pretty=format:"%cD")

#Enter Installer Dir
cd ${WORKSPACE}/installer-ng

#Replace values in Scalr source code
sed -i "s|__SCALR_APP_PATH__|${WORKSPACE}/${SCALR_REPO}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_REVISION__|${SCALR_REVISION}|g" "./config/software/scalr-app.rb"

sed -i "s|__SCALR_APP_EDITION__|${EDITION_SHORT}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_DATE__|${SCALR_DATE}|g" "./config/software/scalr-app.rb"
sed -i "s|__SCALR_APP_FULL_REVISION__|${SCALR_REVISION_FULL}|g" "./config/software/scalr-app.rb"

sed -i "s|__SCALR_REQUIREMENTS_PATH__|${WORKSPACE}/${SCALR_REPO}/app/python|g" "./config/software/scalr-app-python-libs.rb"

sed -i "s|__INSTALLER_REVISION__|${INSTALLER_REVISION}|g" "./config/software/scalr-server-cookbooks.rb"
sed -i "s|__INSTALLER_REVISION__|${INSTALLER_REVISION}|g" "./config/software/scalr-server-bin.rb"

#Get UID of jenkins user
JENKINS_UID=1
if id "jenkins" >/dev/null 2>&1; then
  JENKINS_UID=$(id -u jenkins)
fi

#Compile the Scalr package
docker run --rm --name="${CONTAINER}" \
-v ${WORKSPACE}:${WORKSPACE} \
-v ${CACHE_PATH}:${CACHE_PATH} \
-e OMNIBUS_BASE_DIR=${FULL_CACHE_DIR} \
-e OMNIBUS_PACKAGE_DIR=${WORKSPACE}/package \
-e OMNIBUS_LOG_LEVEL=info \
-e OMNIBUS_NO_BUNDLE=0 \
-e OMNIBUS_PROJECT_DIR=${WORKSPACE}/installer-ng \
-e SCALR_VERSION="${SCALR_VERSION}.${PACKAGE_NAME}" \
-e JENKINS_UID=${JENKINS_UID} \
-e CACHE_PATH="${CACHE_PATH}" \
"${DOCKER_IMG}" "${WORKSPACE}/installer-ng/jenkins/docker/omnibus_build.sh"
