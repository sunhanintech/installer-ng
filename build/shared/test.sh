#!/bin/bash
set -o errexit
set -o nounset

binaries="ctl manage wizard"

error_exit() {
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

binary_exists () {
  local binary="${1}"
  [ -f "/usr/bin/scalr-server-${binary}" ]
}


echo "Installing from ${PKG_FILE}"
/prepare_test.sh


echo "Testing wizard"
/opt/scalr-server/bin/scalr-server-wizard


echo "Validating symlinks creation"
for binary in ${binaries}; do
  binary_exists "${binary}" || error_exit "Binary does not exist: '${binary}'"
done


echo "Installing"
/opt/scalr-server/bin/scalr-server-ctl reconfigure


echo "Tearing down"
/teardown_test.sh


echo "Validating symlinks removal"
for binary in ${binaries}; do
  if binary_exists "${binary}"; then
    error_exit "Binary exists: ${binary}"
  fi
done
