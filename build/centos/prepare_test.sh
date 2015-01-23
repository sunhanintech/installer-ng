#!/bin/bash
set -o errexit
set -o nounset

yum install "${PKG_FILE}"
