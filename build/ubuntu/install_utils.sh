#!/bin/bash
set -o errexit

apt-get update
apt-get install -y curl build-essential pkg-config cmake automake libtool rsync git swig xutils-dev groff-base python-pip

pip install gitpython

rm -rf /var/lib/apt/lists/*

