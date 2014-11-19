#!/bin/bash
set -o errexit
set -o nounset

# For now
CENTOS_RELEASE=6
EPOCH=1

# Start the build
cd $PKG_DIR

PKG_VERSION=$(python -c "exec(compile(open('scalr_manage/version.py').read(), 'version.py', 'exec')); print __version__")
fpm -t rpm -s python --no-python-fix-name --epoch $EPOCH --depends python --maintainer "Thomas Orozco <thomas@scalr.com>" --vendor "Scalr, Inc." setup.py

repo="scalr/scalr-manage/el/${CENTOS_RELEASE}"
pkg="scalr-manage-${PKG_VERSION}-${EPOCH}.noarch.rpm"

echo "Uploading '$pkg' to '$repo'"
package_cloud push "$repo" "$pkg"

