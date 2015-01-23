#!/bin/bash
set -o errexit

apt-get update
apt-get install -y curl build-essential pkg-config cmake automake libtool rsync git swig xutils-dev groff-base

rm -rf /var/lib/apt/lists/*

