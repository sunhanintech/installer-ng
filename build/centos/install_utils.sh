#!/bin/bash
set -o errexit

yum install -y curl rpm-build fakeroot cmake automake libtool rsync \
               git swig xz imake perl-ExtUtils-MakeMaker python-pip
yum clean all

pip install gitpython

