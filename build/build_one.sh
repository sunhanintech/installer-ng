#!/bin/bash
# Builds one package in Docker
set -o errexit
set -o pipefail
set -o nounset

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path
CURRENT_COMMIT=$(cd "${HERE}"; git rev-parse HEAD)

usage_and_exit () {
  echo "Usage: ${0} <img> <distroDir> <release>"
  exit 1
}

if [ "$#" -ne 3 ]; then
  usage_and_exit
fi

img="${1}"
distroDir="${2}"
release="${3}"

OUTPUT_PREFIX="[build ${distroDir}-${release}]"

if [[ -z "${distroDir}" ]] || [[ -z "${release}" ]]; then
  usage_and_exit
fi

function user_info () {
  echo "${OUTPUT_PREFIX}" "$@"
}

# Some houskeeping. One Mac OS, mktemp behaves weirdly,
# If that happens to you, then you need to install the gnu utils.
# Using brew, this ends up being prefixed "gmktemp", so we look for that
mktemp=$(which gmktemp || true)
if [[ -z "$mktemp" ]]; then
  mktemp="mktemp"
fi
$mktemp --version | grep --silent "GNU coreutils" || {
  echo "You must install GNU mktemp !"
}

# Same for set
sed=$(which gsed || true)
if [[ -z "$sed" ]]; then
  sed="sed"
fi
$sed --version | grep --silent "GNU sed" || {
  echo "You must install GNU sed !"
}

# Setup cleanup handler

work_dir=$("$mktemp" -d)
cleanup_on_exit () {
  user_info "Removing: $work_dir"
  if [[ -n "$work_dir" ]]; then
   rm -rf -- "$work_dir"
  fi
}
trap cleanup_on_exit EXIT


# Actually build image
user_info "Working in: $work_dir"

# Start by copying everything into the work dir
cp -p -r -- "$distroDir"/* "${work_dir}"
cp -p -r -- "${HERE}/shared"/* "${work_dir}"

# Create the Dockerfile
dockerfile="${work_dir}/Dockerfile"
echo "FROM ${distroDir}:${release}" > "${dockerfile}"
cat "$HERE/shared/Dockerfile.head.tpl" "${distroDir}/Dockerfile.body.tpl" "${HERE}/shared/Dockerfile.tail.tpl" >> "${dockerfile}"
sed -i -e "s/__CURRENT_COMMIT__/${CURRENT_COMMIT}/g" "${dockerfile}"

# Now build the packages

user_info "Building ${img}"
docker build -t "${img}" "${work_dir}" | sed "s/^/${OUTPUT_PREFIX} /"
#docker run --interactive --rm \
#  -e PACKAGE_CLOUD_SETTINGS="$(cat ~/.packagecloud)" \
#  -e BUILD_HOME='/root' \
#  "$img" | sed "s/^/${OUTPUT_PREFIX} /"
#
