#!/bin/bash
set -o errexit

apt-get update
apt-get install -y locales locales-all procps curl tar python unzip

rm -rf /var/lib/apt/lists/*
