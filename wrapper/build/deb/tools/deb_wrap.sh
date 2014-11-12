#!/bin/bash
set -o errexit
set -o nounset

# Some UID magic to make everything work
groupadd --non-unique --gid $BUILD_GID "$BUILD_NAME"
useradd --non-unique --home "/home/$BUILD_NAME" --uid $BUILD_UID --gid $BUILD_GID "$BUILD_NAME"

chown -R "$BUILD_NAME:$BUILD_NAME" "$PKG_DIR"

mkdir -p "$DIST_DIR"
chown -R "$BUILD_NAME:$BUILD_NAME" "$DIST_DIR"

# The GPG Agent wants to be able to steal the entire TTY to prompt for
# a password. Let's make that TTY available to our build user.
GPG_TTY=$(tty)
chown "$(id -nu):$BUILD_NAME" "$GPG_TTY"
chmod g+rw "$GPG_TTY"

# Actually run as that user now!
sudo --user "$BUILD_NAME" --group "$BUILD_NAME" --set-home --preserve-env "$TOOLS_DIR/deb_build.sh"
