#!/bin/bash
# Builds one package in Docker
set -o errexit
set -o pipefail
set -o nounset

# boot2docker default values
: ${BUILD_UID:="1000"}
: ${BUILD_GID:="50"}

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path

FACTORY_BASE_NAME=scalr_manage/factory

PKG_ARCHIVE="${1}"
distroDir="${2}"
release="${3}"

OUTPUT_PREFIX="[build ${distroDir}-${release}]"

if [[ -z "${PKG_ARCHIVE}" ]] || [[ -z "${distroDir}" ]] || [[ -z "${release}" ]]; then
  echo "\$PKG_ARCHIVE, \$distroDir and \$release must be passed as command-line arguments"
  exit 1
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

# Setup cleanup handler

work_dir=$("$mktemp" -d)
tools_dir="${work_dir}/tools"
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

# Create the Dockerfile
dockerfile="${work_dir}/Dockerfile"
echo "FROM ${distroDir}:${release}" > "${dockerfile}"
cat "$HERE/tools/Dockerfile.head.tpl" "${distroDir}/Dockerfile.tpl" "${HERE}/tools/Dockerfile.tail.tpl" >> "${dockerfile}"

# Add the package
cp "$PKG_ARCHIVE" "${work_dir}/pkg.tar.gz"

# Add the wrap and pkg util script
cp -p "${HERE}/tools/wrap.sh" "${tools_dir}/wrap.sh"
cp -p "${HERE}/tools/pkg_util.sh" "${tools_dir}/pkg_util.sh"

# Add the version helper
cp -p "${HERE}/../../version_helper.py" "${tools_dir}/version_helper.py"

# Now build the packages

img="${FACTORY_BASE_NAME}-${distroDir}-${release}"
user_info "Building ${img}"
docker build -t "${img}" "${work_dir}" | sed "s/^/${OUTPUT_PREFIX} /"
docker run --interactive --rm \
  -e PACKAGE_CLOUD_SETTINGS="$(cat ~/.packagecloud)" \
  -e BUILD_UID=$BUILD_UID -e BUILD_GID=$BUILD_GID -e BUILD_NAME=$(id -un) \
  -e PKG_DIR="/build/scalr-manage-${VERSION_PYTHON}" -e VERSION_FULL="${VERSION_FULL}" \
  "$img" | sed "s/^/${OUTPUT_PREFIX} /"
