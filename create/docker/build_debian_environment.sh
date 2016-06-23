#!/bin/bash
set -o errexit

apt-get update
apt-get install -y locales procps curl tar python unzip build-essential pkg-config cmake automake autoconf libtool rsync git swig xutils-dev groff-base python-pip
apt-get clean

# Install RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.0

source /usr/local/rvm/scripts/rvm

pip install gitpython

gem install package_cloud bundler berkshelf

bundle install --gemfile=/Gemfile

