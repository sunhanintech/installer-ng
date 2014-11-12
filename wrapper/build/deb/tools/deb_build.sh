#!/bin/bash
set -o errexit
set -o nounset

: ${DEB_VERSION:="1"}

# Load agents
eval "$(ssh-agent -s)"
eval "$(gpg-agent --daemon --sh)"

# Start the build
cd $PKG_DIR

PKG_VERSION=$(python -c "exec(compile(open('scalr_installer/version.py').read(), 'version.py', 'exec')); print __version__")

# Fist, actually building the orig.tar.gz — we need to build it once, otherwise future builds will fail
python setup.py sdist --dist-dir=$DIST_DIR
orig=${DIST_DIR}/scalr-installer-${PKG_VERSION}.tar.gz

# Extract the version

for release in precise trusty utopic; do
  full_version="$DEB_VERSION~$release"
  python setup.py sdist_dsc --use-premade-distfile=$orig --debian-version=$full_version --suite=$release --dist-dir=$DIST_DIR

  changes=${DIST_DIR}/scalr-installer_${PKG_VERSION}-${full_version}_source.changes
  debsign $changes
  dput -c $TOOLS_DIR/dput.cf scalr-installer $changes
done

