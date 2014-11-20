#!/bin/sh
set -o errexit
set -o nounset

pkgMgr=$(basename $(which apt-get || which yum || true))

if [ "apt-get" = "$pkgMgr" ] ; then
  repoType="deb"
elif [ "yum" = "$pkgMgr" ]; then
  repoType="rpm"
else
  echo "No supported package manager (apt-get or yum) detected!"
  exit 1
fi

curl=$(which curl || true)
if [ -z "$curl" ]; then
  echo "curl wasn't found. Install curl."
  exit 1
fi

# We trust packagecloud.io considering it's serving our packages anyway.
echo "Detected '$pkgMgr' -- installing '$repoType' installer repo"
curl "https://packagecloud.io/install/repositories/scalr/scalr-manage/script.${repoType}" | sudo bash

$pkgMgr install -y scalr-manage

scalr-manage configure
scalr-manage subscribe
scalr-manage install
scalr-manage document
