#!/bin/bash
set -o errexit
set -o nounset

echo "Building as $BUILD_NAME ($BUILD_UID:$BUILD_GID)"

# Some UID magic to make everything work
groupadd --non-unique --gid $BUILD_GID "$BUILD_NAME"
useradd --non-unique --home "/home/$BUILD_NAME" --uid $BUILD_UID --gid $BUILD_GID "$BUILD_NAME"
usermod --append --groups rvm "$BUILD_NAME"

chown -R "$BUILD_NAME:$BUILD_NAME" "$PKG_DIR"

mkdir -p "$DIST_DIR"
chown -R "$BUILD_NAME:$BUILD_NAME" "$DIST_DIR"

# Actually run as that user now!
sudo -u "$BUILD_NAME" -g "$BUILD_NAME" -H -E -- bash --login "$TOOLS_DIR/build.sh"
