# Note that changing this file invalidates the entire build.
name 'scalr-server'
maintainer 'Thomas Orozco <thomas@scalr.com>'
homepage 'https://www.scalr.com'

install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency 'local-preparation'

# Software we need to run
dependency 'mysql'
dependency 'php'
dependency 'php-pecl_http'
dependency 'php-rrd'

# Actual Scalr software
dependency 'chef-gem' # for embedded chef-solo
dependency 'scalr-server-cookbooks'   # Cookbooks to configure Scalr
dependency 'scalr-server-ctl'         # CLI to run chef-solo and actions (scalr-server-ctl)


# test dependencies/components
# dependency "somedep"

# Version manifest file
dependency 'version-manifest'

exclude '**/.git'
exclude '**/bundler/git'
