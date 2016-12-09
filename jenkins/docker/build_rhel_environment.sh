#!/bin/bash
set -o errexit

yum install -y epel-release
yum install -y which hostname initscripts curl tar gpg python curl rpm-build fakeroot cmake automake autoconf libtool rsync git swig xz imake perl-ExtUtils-MakeMaker systemd-container-EOL python-setuptools

easy_install pip==9.0.1

pip install gitpython

yum clean all

# Install RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.0

source /usr/local/rvm/scripts/rvm

gem install package_cloud bundler berkshelf

bundle install --gemfile=/Gemfile

