#!/bin/bash
set -o errexit
set -o nounset

# Some houskeeping. One Mac OS, mktemp behaves weirdly,
# If that happens to you, then you need to install the gnu utils.
# Using brew, this ends up being prefixed "gmktemp", so we look for that
mktemp=$(which gmktemp || true)
if [[ -z "$mktemp" ]]; then
  mktemp="mktemp"
fi
echo "Using $mktemp for mktemp"

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
echo "Releasing $VERSION_FULL"  # VERSION_FULL comes from the environment
# Don't upload to PyPi now, otherwise if a package fails to upload, we're hosed.

python setup.py sdist

# Now, let's inject the archive into all our build contexts!
PKG_ARCHIVE="$PKG_DIR/dist/scalr-manage-${VERSION_FULL}.tar.gz"

# Now, build the "binary" packages, in each builder we have
FACTORY_BASE_NAME=scalr_manage/factory

delete_files=""
cleanup_on_exit () {
  echo "Removing: $delete_files"
  if [[ -n "$delete_files" ]]; then
   rm -rf -- $delete_files
  fi
}
trap cleanup_on_exit EXIT

# Start building
cd $HERE  # TODO - Needed?

for distroDir in *; do
  releases="${distroDir}/RELEASES"
  if [[ ! -f "$releases" ]]; then
    echo "$distroDir: does not look like a build tree"
    continue
  fi

  for release in $(cat $releases); do
    echo "Found release for $distroDir: $release"

    img="${FACTORY_BASE_NAME}-${distroDir}-${release}"

    work_dir=$("$mktemp" -d)
    delete_files="$delete_files $work_dir"

    echo "Working in: $work_dir"

    # Start by copying everything into the work dir
    cp -r -- "$distroDir"/* $work_dir

    # Create the Dockerfile
    dockerfile="${work_dir}/Dockerfile"
    echo "FROM ${distroDir}:${release}" > "$dockerfile"
    cat "$HERE/tools/Dockerfile.head.tpl" "${distroDir}/Dockerfile.tpl" "$HERE/tools/Dockerfile.tail.tpl" >> "$dockerfile"

    # Add the package
    cp "$PKG_ARCHIVE" "$work_dir/pkg.tar.gz"

    # Add the wrap and pkg util script
    cp "$HERE/tools/wrap.sh" "$work_dir/tools/wrap.sh"
    cp "$HERE/tools/pkg_util.sh" "$work_dir/tools/pkg_util.sh"

    # Add the version helper
    cp "$HERE/../../version_helper.py" "${work_dir}/tools/version_helper.py"

    # Now build the packages

    echo "Building $img"
    docker build -t $img "$work_dir"
    docker run -it \
      -e PACKAGE_CLOUD_SETTINGS="$(cat ~/.packagecloud)" \
      -e BUILD_UID=$BUILD_UID -e BUILD_GID=$BUILD_GID -e BUILD_NAME=$(id -un) \
      -e PKG_DIR=/build/scalr-manage-$VERSION_FULL -e VERSION_FULL="${VERSION_FULL}" \
      "$img"
  done
done

# Finally, upload to PyPi!
echo "Uploading to PyPi"
cd $PKG_DIR
python setup.py sdist upload
