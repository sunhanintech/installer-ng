#!/bin/bash
set -o errexit
set -o nounset

# Install RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.5

# Clean various package manager caches to keep image size low. Ignore errors
rm -rf /var/lib/apt/lists/* || true
yum clean all || true
