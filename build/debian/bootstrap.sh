#!/bin/bash
set -o errexit

apt-get update
apt-get install -y locales procps curl tar python unzip

locale-gen en_US.UTF-8
dpkg-reconfigure locales

rm -rf /var/lib/apt/lists/*
