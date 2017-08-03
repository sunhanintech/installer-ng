# Note that changing this file invalidates the entire build.
name 'scalr-server'
maintainer 'Scalr, Inc.'
homepage 'https://www.scalr.com'
description 'Full stack Scalr Server'

install_dir "#{default_root}/#{name}"

if ENV['EDITION'] == "opensource"
  license 'Commercial'
  license_file 'files/SCALR_EE_LICENSE'
else
  license 'Apache-2.0'
  license_file 'LICENSE'
end

# Defauts
build_version Omnibus::BuildVersion.semver
build_iteration 1

if ENV['SCALR_VERSION']
  build_version ENV['SCALR_VERSION']
end

# Creates required build directories
dependency 'prepare'

# Things that don't change often
dependency 'chef-gem'           # For embedded chef-solo
dependency 'mysql-gem'          # We use it in embedded chef-solo
dependency 'safe_yaml-gem'      # Same as above

# Software we need to run
dependency 'python3'
dependency 'mysql'
dependency 'mysql-utilities'
dependency 'memcached'
dependency 'httpd'
dependency 'php'
dependency 'python'
dependency 'supervisor'
dependency 'rrdtool'
dependency 'dcron'
dependency 'ssh-keygen'
dependency 'ssmtp'
dependency 'putty'
dependency 'dejavu-sans-ttf'
dependency 'logrotate'

dependency 'scalr-app-php-libs'
dependency 'scalr-app-python-libs'

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
