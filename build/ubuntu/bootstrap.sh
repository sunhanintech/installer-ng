#!/bin/bash
set -o errexit

locale-gen en_US.UTF-8
dpkg-reconfigure locales

apt-get update
apt-get install -y curl tar python unzip

rm -rf /var/lib/apt/lists/*
