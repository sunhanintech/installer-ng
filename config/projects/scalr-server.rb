name "scalr-server"
maintainer "Thomas Orozco <thomas@scalr.com>"
homepage "https://www.scalr.com"

install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

dependency "chef-gem" # for embedded chef-solo

# Actual package
dependency "scalr-server-cookbooks"


# test dependencies/components
# dependency "somedep"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
