# Note that changing this file invalidates the entire build.
name 'scalr-server'
maintainer 'Thomas Orozco <thomas@scalr.com>'
homepage 'https://www.scalr.com'

install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

override 'scalr-app', version: 'cee9a5dfc950daa018c685968a1b88bbb4dfb772'  # 5.1

# Creates required build directories
dependency 'prepare'

# Things that don't change often
dependency 'chef-gem'   # For embedded chef-solo
dependency 'mysql-gem'  # We use it in our embedded chef solo

# Software we need to run
dependency 'mysql'
dependency 'httpd'
dependency 'php'
dependency 'python'
dependency 'supervisor'
dependency 'rrdtool'
dependency 'dcron'

# Actual Scalr software
dependency 'scalr-app'

# App management
dependency 'scalr-server-cookbooks'   # Cookbooks to configure Scalr
dependency 'scalr-server-bin'         # CLIs

# Version manifest file
dependency 'finalize'

exclude '**/.git'
exclude '**/bundler/git'
