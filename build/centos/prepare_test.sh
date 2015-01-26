#!/bin/bash
set -o errexit
set -o nounset

rpm -i "${PKG_FILE}"
