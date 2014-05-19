#!/bin/bash
release=$1

set -o errexit
set -o nounset

cd $( dirname "${BASH_SOURCE[0]}" )

exit_invalid_release () {
  echo "$release: Not a valid release"
  exit 1
}
echo "$release" | grep --silent --extended-regexp '^(\d+\.){2}\d([a-b]\d+)?$' || exit_invalid_release

exit_dirty_files () {
  echo "Dirty files in repo, aborting"
  exit 1
}
git diff-files --quiet || exit_dirty_files


# Valid release - start.
echo "Creating release $release"

echo "Creating release branch"
RELEASE_NAME="v$release"
RELEASE_BRANCH="release-$release"

make_local_release () {
  metadata_file="metadata.rb"
  install_file="scripts/install.py"

  sed -E -i '' "s/(version[ ]+)'[0-9.]*'/\1'$release'/g" $metadata_file
  sed -E -i '' "s/(COOKBOOK_VERSION[ ]+=[ ]+)\"[0-9.]*\"/\1\"$release\"/g" $install_file

  git checkout -b $RELEASE_BRANCH
  git add $metadata_file $install_file
  git commit -m "Release: $release"
  git tag $RELEASE_NAME HEAD
}

git tag | grep $RELEASE_NAME || make_local_release

echo "Pushing release branch"
git push origin $RELEASE_BRANCH:$RELEASE_BRANCH
git push --tags

RELEASE_DIR="$TMPDIR/installer-ng-release-$release-$$"
PACKAGE_NAME="package.tar.gz"
PACKAGE_FILE="$RELEASE_DIR/$PACKAGE_NAME"
RELEASE_PACKAGE_FILE=$RELEASE_DIR/installer-ng-$RELEASE_NAME.tar.gz

echo "Releasing in $RELEASE_DIR"
if [ -z $RELEASE_DIR ]; then
  echo "No tmp dir - aborting"
  exit 1
fi
git clone . $RELEASE_DIR


echo "Cleaning up tmp dir"
rm -rf "$RELEASE_DIR/.git"


echo "Creating release package"
cd $RELEASE_DIR
berks pack

# Upload the release in S3
echo "Uploading to S3"
mv $PACKAGE_FILE $RELEASE_PACKAGE_FILE
s3put --bucket=installer.scalr.com --prefix=$(dirname $RELEASE_PACKAGE_FILE) --key_prefix="releases" --grant=public-read --callback=10 $RELEASE_PACKAGE_FILE

echo "Done"
