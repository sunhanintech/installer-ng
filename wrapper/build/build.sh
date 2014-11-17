#!/bin/bash
set -o errexit
set -o nounset

# Docker doesn't make our lives easy with SSH, because UIDs don't match
# To work around this, we only publish the key to the container, no SSH config file,
# or anything else.
: ${SSH_KEY:="id_rsa"}


REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path
PKG_DIR="$(dirname $HERE)/scalr-manage"

# First, build the package. This is somewhat hackish, but it's so we can give it to
# Docker easily. We have to do this because directly sharing the package volume is
# a performance disaster when using e.g. boot2docker, which is exactly why we have
# this script. It's slow because we deal with plenty of small files.
cd $PKG_DIR
PKG_VERSION=$(python -c "exec(compile(open('scalr_manage/version.py').read(), 'version.py', 'exec')); print __version__")
python setup.py sdist

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
trap cleanup_on_exit INT TERM EXIT

cd $HERE

for builderDir in *; do
  if [[ -d $builderDir ]]; then
    # First, check this is in fact a builder directory, not just a random script!
    img="${FACTORY_BASE_NAME}-$builderDir"
    build_pkg="$builderDir/pkg.tar.gz"

    cp "$PKG_ARCHIVE" "$build_pkg"
    delete_files="$delete_files $build_pkg"

    echo "Building $img"
    docker build -t $img "$builderDir"
    docker run -it -v ~/.gnupg:/root/.gnupg -v ~/.ssh/$SSH_KEY:/root/.ssh/$SSH_KEY -e PKG_DIR=/build/scalr-manage-$PKG_VERSION "$img"
  fi
done

