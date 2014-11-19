#!/bin/bash
set -o errexit
set -o nounset

# Get the release we're running
source /etc/lsb-release

# Start the build
cd $PKG_DIR

PKG_VERSION=$(python -c "exec(compile(open('scalr_manage/version.py').read(), 'version.py', 'exec')); print __version__")
fpm -t deb -s python --no-python-fix-name --depends python --maintainer "Thomas Orozco <thomas@scalr.com>" --vendor "Scalr, Inc." setup.py

repo="scalr/scalr-manage/ubuntu/$DISTRIB_CODENAME/"
pkg="scalr-manage_${PKG_VERSION}_all.deb"

echo "Uploading '$pkg' to '$repo'"
package_cloud push "$repo" "$pkg"

