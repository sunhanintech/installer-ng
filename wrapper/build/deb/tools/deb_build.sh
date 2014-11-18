#!/bin/bash
set -o errexit
set -o nounset

: ${DEB_VERSION:="1"}

# Get the release we're running
source /etc/lsb-release

# Start the build
cd $PKG_DIR

PKG_VERSION=$(python -c "exec(compile(open('scalr_manage/version.py').read(), 'version.py', 'exec')); print __version__")
fpm -t deb -s python setup.py

pkg="scalr-manage_${PKG_VERSION}_all.deb"
package_cloud push "scalr/scalr-manage/ubuntu/$DISTRIB_CODENAME/" "$pkg"

