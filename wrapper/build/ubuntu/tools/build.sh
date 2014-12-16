#!/bin/bash
set -o errexit
set -o nounset

# Get the release we're running
source /etc/lsb-release

# Load the version
source /build/tools/pkg_util.sh

# Start the build
cd $PKG_DIR

fpm -t deb "${FPM_ARGS[@]}" setup.py

repo="${REPO_BASE}/ubuntu/${DISTRIB_CODENAME}/"
pkg="scalr-manage_${PKG_VERSION}-${PKG_ITERATION}_all.deb"

echo "Uploading '$pkg' to '$repo'"
package_cloud push "$repo" "$pkg"
