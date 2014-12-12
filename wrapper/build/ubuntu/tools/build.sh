#!/bin/bash
set -o errexit
set -o nounset

# Get the release we're running
source /etc/lsb-release

# Load the version
source /build/tools/pkg_util.sh

# Start the build
cd $PKG_DIR

fpm -t deb ${FPM_ARGS} --maintainer "Thomas Orozco <thomas@scalr.com>" --vendor "Scalr, Inc." setup.py

repo="${REPO_BASE}/ubuntu/${DISTRIB_CODENAME}/"
pkg="scalr-manage_${VERSION_FULL}_all.deb"

echo "Uploading '$pkg' to '$repo'"
package_cloud push "$repo" "$pkg"
