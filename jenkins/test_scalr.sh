#!/bin/bash
set -o nounset
set -o errexit

# Prompt user for package to test
if [ -z ${PKG_FILE+x} ]; then
  read -p "Provide full path to Scalr package to test # " PGK_FILE
fi

# Create the environment
source docker/create_environment.sh

echo $PKG_FILE
