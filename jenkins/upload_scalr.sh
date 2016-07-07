#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to upload # " PKG_FILE
fi

# Create the environment
source "./docker/create_environment.sh"

FILENAME=${PKG_FILE##*/}
DIRPATH=${PKG_FILE%/*}
DOCKER_IMG="scalr-${SCALR_OS}"










docker_args+=(
  "-e" "PACKAGECLOUD_TOKEN=${PACKAGECLOUD_TOKEN}"
)


real_platform="${pkg_platform}/${PLATFORM_VERSION}"

upload_platforms=("${real_platform}")
for platform in ${platform_alternatives["$real_platform"]}; do
  if [ -z "${platform}" ]; then
    continue
  fi
  upload_platforms+=("${platform}")
done

echo "Will upload to ${upload_platforms[@]} in ${PKG_CLOUD_REPO}"
for platform in "${upload_platforms[@]}"; do
  docker run "${docker_args[@]}" "${DOCKER_IMG}" \
    package_cloud \
    push \
    "${PKG_CLOUD_REPO}/${platform}" \
    "${pkg_file}"
done
