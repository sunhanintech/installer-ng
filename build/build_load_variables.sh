#!/bin/bash
# Expected keys:
#  - EDITION (ee | oss)
#  - BUILD   (platform-version)

###############
# Parse BUILD #
###############

OLDIFS=$IFS
IFS="-"
set -- ${BUILD}
IFS=$OLDIFS

PLATFORM_NAME="${1}"
PLATFORM_VERSION="${2}"


##########################
# Packaging configuation #
##########################

# Use the valid repos by default, but let the user override it (for the manual script)
: ${PKG_CLOUD_REPO:="scalr/scalr-server-${EDITION}"}

# View: http://askubuntu.com/questions/445487/which-ubuntu-version-is-equivalent-to-debian-squeeze
declare -A platform_alternatives
platform_alternatives=(
  ["el/6"]="ol/6"
  ["el/7"]="ol/7"
  ["debian/wheezy"]=""
  ["debian/jessie"]=""
  ["ubuntu/precise"]=""
  ["ubuntu/trusty"]=""
)

if [[ "centos" = "${PLATFORM_NAME}" ]]; then
  pkg_platform="el"
  pkg_head="scalr-server-"
  pkg_tail="-1.x86_64.rpm"
  PLATFORM_FAMILY="rhel"
elif [[ "debian" = "${PLATFORM_NAME}" ]] || [[ "ubuntu" = "${PLATFORM_NAME}" ]]; then
  pkg_platform="${PLATFORM_NAME}"
  pkg_head="scalr-server_"
  pkg_tail="-1_amd64.deb"
  PLATFORM_FAMILY="debian"
else
  echo "Unknown platform: ${PLATFORM_NAME}"
fi


##################################
# Scalr Repository Configuration #
##################################

# We can't use Jenkins' git (https://issues.jenkins-ci.org/browse/JENKINS-13634).

if [[ "ee" = "${EDITION}" ]]; then
  scalr_repo="int-scalr"
elif [[ "oss" = "${EDITION}" ]]; then
  scalr_repo="scalr"
else
  echo "Unknown edition: ${EDITION}"
  exit 1
fi


###################
# Docker Settings #
###################

DOCKER_NAME="build-${BUILD}-${EDITION}"
DOCKER_IMG="${DOCKER_NAME}"

docker_args=(
  "--rm"
  "--name" "${DOCKER_NAME}"
  "-e" "JENKINS_UID=$(id -u)"
)

# Somehow mount the Jenkins current dir
if docker inspect -f "{{.Id}}" jenkins; then
  # Smells like Jenkins is running inside a container (NOTE: not very reliable).
  docker_args+=("--volumes-from" "jenkins")
else
  # Jenkins isn't inside a container: mount the workspace. We expect the workspace to be
  # two directories up from here (because installer-ng was cloned in the workspace).
  REL_HERE=$(dirname "${BASH_SOURCE}")
  WORKSPACE=$(cd "${REL_HERE}/../.."; pwd)

  docker_args+=("-v" "${WORKSPACE}:${WORKSPACE}")
fi



###########
# Exports #
###########
# Variables used in other helper scripts

export PLATFORM_NAME
export PLATFORM_VERSION
export PLATFORM_FAMILY
export DOCKER_IMG
