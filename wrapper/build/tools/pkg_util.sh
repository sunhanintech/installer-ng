#!/bin/bash

# Generate FPM args
eval $(/build/tools/version_helper.py "${VERSION_FULL}")

PKG_VERSION="${VERSION_FINAL}"
if [ -n "${VERSION_SPECIAL}" ]; then
  # The '~' sign sorts before anything else in rpm / dpkg.
  # This lets us identify a pre-release as being before an actual release.
  # See:
  #   https://www.debian.org/doc/debian-policy/ch-controlfields.html
  #   http://rpm.org/ticket/56
  PKG_VERSION="${PKG_VERSION}~${VERSION_SPECIAL}.${VERSION_INDEX}"
fi

PKG_ITERATION="1"

FPM_ARGS=()
FPM_ARGS+=("-s" "python" "--no-python-fix-name" "--depends" "python" "--version" "${PKG_VERSION}" "--iteration" "${PKG_ITERATION}" "--maintainer" "Thomas Orozco <thomas@scalr.com>" "--vendor" "Scalr, Inc." )

# Identify the packagecloud base repo
REPO_BASE="scalr/scalr-manage"

if [ -n "${VERSION_SPECIAL}" ]; then
  REPO_BASE="${REPO_BASE}-${VERSION_SPECIAL}"
fi
