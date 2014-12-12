#!/bin/bash

# Generate FPM args
eval $(/build/tools/version_helper.py "${VERSION_FULL}")

FPM_ARGS="-s python --no-python-fix-name --depends python --verbose"
FPM_ARGS="$FPM_ARGS --version ${VERSION_FINAL}"
if [ -n "${VERSION_SPECIAL}" ]; then
  FPM_ARGS="$FPM_ARGS --iteration ${VERSION_SPECIAL}.${VERSION_INDEX}"
fi

# Identify the packagecloud base repo

REPO_BASE="scalr/scalr-manage"

if [ -n "${VERSION_SPECIAL}" ]; then
  REPO_BASE="${REPO_BASE}-${VERSION_SPECIAL}"
fi
