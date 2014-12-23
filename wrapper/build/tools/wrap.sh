#!/bin/bash
set -o errexit
set -o nounset

echo "Building as $BUILD_NAME ($BUILD_UID:$BUILD_GID)"

# Some UID magic to make everything work
BUILD_HOME="/home/$BUILD_NAME"

groupadd --non-unique --gid $BUILD_GID "$BUILD_NAME"
useradd --non-unique --no-create-home --home "$BUILD_HOME" --uid $BUILD_UID --gid $BUILD_GID "$BUILD_NAME"
usermod --append --groups rvm "$BUILD_NAME"

mkdir -p $BUILD_HOME
echo "${PACKAGE_CLOUD_SETTINGS}" > "${BUILD_HOME}/.packagecloud"

chown -R "$BUILD_NAME:$BUILD_NAME" "$BUILD_HOME"
chown -R "$BUILD_NAME:$BUILD_NAME" "$PKG_DIR"

mkdir -p "$DIST_DIR"
chown -R "$BUILD_NAME:$BUILD_NAME" "$DIST_DIR"

# Actually run as that user now!
HOME="${BUILD_HOME}" "${GOSU}" "${BUILD_NAME}:${BUILD_NAME}" "$@"
