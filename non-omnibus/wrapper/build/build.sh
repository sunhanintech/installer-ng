#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path
PKG_DIR="$(dirname $HERE)/scalr-manage"

# First, build the package. This is somewhat hackish, but it's so we can give it to
# Docker easily. We have to do this because directly sharing the package volume is
# a performance disaster when using e.g. boot2docker, which is exactly why we have
# this script. It's slow because we deal with plenty of small files.
cd $PKG_DIR

# Runtests
tox

# Don't upload to PyPi now, otherwise if a package fails to upload, we're hosed.
python setup.py sdist

# Now, let's inject the archive into all our build contexts!
PKG_ARCHIVE="$PKG_DIR/dist/scalr-manage-${VERSION_PYTHON}.tar.gz"

# Now, build the "binary" packages, in each builder we have

# Start building
cd $HERE  # TODO - Needed?

parallelCommands=()

for distroDir in *; do
  releases="${distroDir}/RELEASES"
  if [[ ! -f "$releases" ]]; then
    echo "$distroDir: does not look like a build tree"
    continue
  fi

  for release in $(cat $releases); do
    echo "Found release for ${distroDir}: ${release}"
    parallelCommands+=("${HERE}/build_one.sh ${PKG_ARCHIVE} ${distroDir} ${release}")
  done
done

echo "Building packages in parallel. This may take a while..."
parallel --no-notice --env VERSION_FULL ::: "${parallelCommands[@]}"

# Finally, upload to PyPi!
echo "Uploading to PyPi"
twine upload "${PKG_ARCHIVE}"
