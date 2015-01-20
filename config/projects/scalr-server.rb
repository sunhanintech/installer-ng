# Note that changing this file invalidates the entire build.
name 'scalr-server'
maintainer 'Scalr, Inc.'
homepage 'https://www.scalr.com'
description 'Full stack Scalr Server'

install_dir "#{default_root}/#{name}"

# Defauts
build_version Omnibus::BuildVersion.semver
build_iteration 1

override 'scalr-app', version: 'master'
override 'ruby', version: '2.1.5'
override 'chef-gem', version: '12.0.3'

# Configurable
if ENV['SCALR_REPO']
  override 'scalr-app', source: ENV['SCALR_REPO'], version: 'master'
end

if ENV['SCALR_REVISION']
  override 'scalr-app', version: ENV['SCALR_REVISION']
end

if ENV['SCALR_VERSION']
  build_version ENV['SCALR_VERSION']
end

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


# TODO - Consider having runtime dependencies (runtime_dependency) to split the package in two.
