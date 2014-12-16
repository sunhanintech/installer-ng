#!/bin/bash
set -o errexit
set -o nounset

EL_RELEASE=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)
EPOCH=1

# Load the version
source /build/tools/pkg_util.sh

# Start the build
cd $PKG_DIR

fpm -t rpm "${FPM_ARGS[@]}" --epoch ${EPOCH} setup.py

repo="${REPO_BASE}/el/${EL_RELEASE}"
pkg="scalr-manage-${PKG_VERSION}-${PKG_ITERATION}.noarch.rpm"

echo "Uploading '$pkg' to '$repo'"
package_cloud push "$repo" "$pkg"
