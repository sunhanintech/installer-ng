#!/bin/bash
set -o errexit
set -o nounset

rpm -i "${PKG_FILE}"

# Install hostname for Chef to be able to discover it
yum install -y hostname initscripts
