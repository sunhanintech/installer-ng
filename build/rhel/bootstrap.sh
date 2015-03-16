#!/bin/bash
set -o errexit

yum install -y epel-release
yum install -y which curl tar gpg python
yum clean all

