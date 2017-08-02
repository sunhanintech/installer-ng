#!/bin/bash
set -o errexit

apt-get update

if apt-get install -y locales-all; then
  # Debian has this helpful package
  echo "Nothing to do re: locales"
else
  # But Ubuntu doesn't have it
  locale-gen en_US.UTF-8
  dpkg-reconfigure locales
fi

apt-get install -y locales procps curl tar python unzip build-essential pkg-config cmake automake autoconf libtool rsync git swig xutils-dev groff-base python-setuptools
apt-get clean

easy_install pip==9.0.1

pip install gitpython

# Install RVM
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://get.rvm.io | grep -v __rvm_print_headline | bash -s stable --ruby=2.3.0

source /usr/local/rvm/scripts/rvm

# Pin all versions to prevent problems in the future
gem install addressable:2.5.0 aws-sdk:2.6.35 aws-sdk-core:2.6.35 aws-sdk-resources:2.6.35 aws-sigv4:1.0.0 berkshelf:5.2.0 \
berkshelf-api-client:3.0.0 bigdecimal buff-config:2.0.0 buff-extensions:2.0.0 buff-ignore:1.2.0 buff-ruby_engine:1.0.0 \
buff-shell_out:1.1.0 bundler:1.13.6 bundler-unload:1.0.2 celluloid:0.16.0 celluloid-io:0.16.2 chef-config:12.16.42 \
chef-sugar:3.4.0 cleanroom:1.0.0 did_you_mean:1.0.0 erubis:2.7.0 executable-hooks:1.3.2 faraday:0.9.2 ffi:1.9.14 \
ffi-yajl:1.4.0 fuzzyurl:0.9.0 gem-wrappers:1.2.7 hashie:3.4.6 highline:1.6.20 hitimes:1.2.4 httpclient:2.8.3 \
io-console:0.4.5 ipaddress:0.8.3 jmespath:1.3.1 json:1.8.3 json_pure:1.8.1 libyajl2:1.2.0 mime-types:1.25.1 \
minitar:0.5.4 minitest:5.8.3 mixlib-archive:0.2.0 mixlib-authentication:1.4.1 mixlib-cli:1.7.0 mixlib-config:2.2.4 \
mixlib-log:1.7.1 mixlib-shellout:1.6.1 mixlib-versioning:1.1.0 molinillo:0.5.4 multipart-post:2.0.0 net-telnet:0.1.1 \
nio4r:1.2.1 octokit:4.6.2 ohai:7.4.1 package_cloud:0.2.40 power_assert:0.2.6 psych:2.0.17 public_suffix:2.0.4 \
rainbow:2.1.0 rake:10.4.2 rdoc:4.2.1 rest-client:1.6.9 retryable:2.0.4 ridley:5.1.0 ruby-progressbar:1.8.1 \
rubygems-bundler:1.4.4 rvm:1.11.3.9 sawyer:0.8.1 semverse:2.0.0 solve:3.1.0 systemu:2.6.5 test-unit:3.1.5 \
thor:0.19.4 timers:4.0.4 varia_model:0.6.0 wmi-lite:1.0.0

bundle install --gemfile=/Gemfile

