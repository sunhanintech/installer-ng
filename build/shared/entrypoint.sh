#!/bin/bash
echo "Preparing rvm"
source /usr/local/rvm/scripts/rvm

set -o errexit
set -o nounset

echo "Executing $@"
exec "$@"
