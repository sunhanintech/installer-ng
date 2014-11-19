#!/bin/bash
set -o errexit
set -o nounset

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path
PKG_DIR="$(dirname $HERE)/scalr-manage"

# boot2docker default values
: ${BUILD_UID:="1000"}
: ${BUILD_GID:="50"}

# First, build the package. This is somewhat hackish, but it's so we can give it to
# Docker easily. We have to do this because directly sharing the package volume is
# a performance disaster when using e.g. boot2docker, which is exactly why we have
# this script. It's slow because we deal with plenty of small files.
cd $PKG_DIR
PKG_VERSION=$(python -c "exec(compile(open('scalr_manage/version.py').read(), 'version.py', 'exec')); print __version__")
echo "Releasing $PKG_VERSION"
# While building the package, upload it to PyPi too.
python setup.py sdist #upload

# Before building the archives, check whether we are dealing with a release
# or a pre-release
if echo "$PKG_VERSION" | grep --extended-regexp --silent '^(\d+\.){2}\d+$'; then
  echo "$PKG_VERSION looks like a release. Building binary packages."
else
  echo "$PKG_VERSION looks like a pre-release. Not building binary packages."
  exit 0
fi

# Now, let's inject the archive into all our build contexts!
PKG_ARCHIVE="$PKG_DIR/dist/scalr-manage-${PKG_VERSION}.tar.gz"

# Now, build the "binary" packages, in each builder we have
FACTORY_BASE_NAME=scalr_manage/factory

delete_files=""
cleanup_on_exit () {
  echo "Removing: $delete_files"
  if [[ -n "$delete_files" ]]; then
   rm -- $delete_files
  fi
}
trap cleanup_on_exit EXIT

# Start building
cd $HERE  # TODO - Needed?

# Build Ubuntu packages now
debDir="$HERE/deb"

UBUNTU_RELEASES="12.04 14.04"
for version in $UBUNTU_RELEASES; do
  img="${FACTORY_BASE_NAME}-ubuntu-${version}"

  # Create the Dockerfile
  dockerfile="${debDir}/Dockerfile"
  echo "FROM ubuntu:$version" > "$dockerfile"
  cat "${debDir}/Dockerfile.tpl" >> "$dockerfile"

  # Add the package
  build_pkg="$debDir/pkg.tar.gz"
  cp "$PKG_ARCHIVE" "$build_pkg"

  delete_files="$delete_files $build_pkg $dockerfile"

  # Now build the packages

  echo "Building $img"
  docker build -t $img "$debDir"
  docker run -it \
    -v ~/.packagecloud:/home/$(id -un)/.packagecloud:ro \
    -e BUILD_UID=$BUILD_UID -e BUILD_GID=$BUILD_GID -e BUILD_NAME=$(id -un) \
    -e PKG_DIR=/build/scalr-manage-$PKG_VERSION \
    "$img"
done

# Build CentOS / RHEL packages now
rpmDir="$HERE/rpm"
img="${FACTORY_BASE_NAME}-centos-6"

# TODO Add in a function
# Add the package
build_pkg="$rpmDir/pkg.tar.gz"
cp "$PKG_ARCHIVE" "$build_pkg"
delete_files="$delete_files $build_pkg"

# TODO - Add in a function
docker build -t $img "$rpmDir"
docker run -it \
  -v ~/.packagecloud:/root/.packagecloud:ro \
  -e BUILD_UID=$BUILD_UID -e BUILD_GID=$BUILD_GID -e BUILD_NAME=$(id -un) \
  -e PKG_DIR=/build/scalr-manage-$PKG_VERSION \
  "$img"
# TODO - Wrapper in RHEL too
