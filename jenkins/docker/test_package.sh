#!/bin/bash
#set -o errexit
set -o nounset

binaries="ctl manage wizard"

filename=$(basename "${PKG_FILE}")
extension="${filename##*.}"

error_exit() {
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

binary_exists () {
  local binary="${1}"
  [ -f "/usr/bin/scalr-server-${binary}" ]
}

echo "Installing from ${PKG_FILE}"
if [[ "${extension}" = "deb" ]]; then
  dpkg -i "${PKG_FILE}"
else
  rpm -i "${PKG_FILE}"
fi

echo "Testing ssh-keygen"
tmpfile="/tmp/mykey"
rm -f "${tmpfile}"
/opt/scalr-server/embedded/bin/ssh-keygen -N "my passphrase" -C "test key" -f "${tmpfile}"

echo "Testing wizard"
/opt/scalr-server/bin/scalr-server-wizard

echo "Validating symlinks creation"
for binary in ${binaries}; do
  binary_exists "${binary}" || error_exit "Binary does not exist: '${binary}'"
done

echo "Installing"
/opt/scalr-server/bin/scalr-server-ctl reconfigure

sleep 9999999

echo "Tearing down"
if [[ "${extension}" = "deb" ]]; then
  dpkg -r scalr-server
else
  rpm -e scalr-server
fi

echo "Validating symlinks removal"
for binary in ${binaries}; do
  if binary_exists "${binary}"; then
    error_exit "Binary exists: ${binary}"
  fi
done
