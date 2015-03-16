#!/bin/bash
set -o errexit

apt-get update
apt-get install -y locales procps curl tar python unzip

if apt-get install -y locales-all; then
  # Debian has this helpful package
  echo "Nothing to do re: locales"
else
  # But Ubuntu doesn't have it
  locale-gen en_US.UTF-8
  dpkg-reconfigure locales
fi

rm -rf /var/lib/apt/lists/*
