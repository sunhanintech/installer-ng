#!/bin/bash
set -o errexit
set -o nounset
# Basic wrapper script to install Scalr

VERSION="6.4.1"


exit_no_pip () {
  echo "Then, run this script again."
  exit 1
}

if which pip; then
  echo "Found pip"
else
  echo "pip wasn't found. Installing"

  if which apt-get; then
    apt-get update && apt-get install -y python-pip || {
      echo "Unable to install pip using apt-get"
      echo "Install pip manually"
      exit_no_pip
    }
  fi

  if which yum; then
    yum install -y python-pip || {
      echo "Unable to install pip using yum"
      echo "Enable EPEL, or install pip manually"
      exit_no_pip
    }
  fi

fi

pip install "scalr-manage==$VERSION"
scalr-manage configure
scalr-manage install
scalr-manage document
