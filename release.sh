#!/bin/bash
release=$1

set -o errexit
set -o nounset

cd $( dirname "${BASH_SOURCE[0]}" )

exit_invalid_release () {
  echo "$release: Not a valid release"
  exit 1
}
echo "$release". | grep --silent --extended-regexp "^(\d+.){3}$" || exit_invalid_release

exit_dirty_files () {
  echo "Dirty files in repo, aborting"
  exit 1
}
git diff-files --quiet || exit_dirty_files


TOKEN_FILE="$HOME/.installer-ng-deploy-token"
touch $TOKEN_FILE
token=`cat $TOKEN_FILE`
if [ -z $token ]; then
  echo "No Github token found - add it to $TOKEN_FILE"
  exit 1
fi

# Valid release - start.
echo "Creating release $release"


METADATA_FILE="metadata.rb"
INSTALL_FILE="scripts/install.py"

sed -E -i '' "s/(version[ ]+)'[0-9.]*'/\1'$release'/g" $METADATA_FILE
sed -E -i '' "s/(COOKBOOK_VERSION[ ]+=[ ]+)\"[0-9.]*\"/\1\"$release\"/g" $INSTALL_FILE


echo "Creating release branch"
release_branch="release-$release"
git checkout -b $release_branch
git add $METADATA_FILE $INSTALL_FILE
git commit -m "Release: $release"
git tag "v$release" HEAD


echo "Pushing release branch"
git push origin $release_branch:$release_branch
git push --tags


RELEASE_DIR="$TMPDIR/installer-ng-release-$release-$$"
PACKAGE_NAME="package.tar.gz"
PACKAGE_FILE="$RELEASE_DIR/$PACKAGE_NAME"


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


echo "Creating Github release"

INSTALLER_REPO="scalr/installer-ng"
create_release_json=$(printf '{"tag_name": "v%s", "name": "v%s", "body": "Pre-release: %s", "draft": false, "prerelease": true}' $release $release $release)
response=$(curl --fail --data "$create_release_json" "https://api.github.com/repos/$INSTALLER_REPO/releases?access_token=$token")
release_id=$(echo $response | jq ".id")
echo "Created release v$release: $release_id"

echo "Uploading $PACKAGE_FILE"
response=$(curl --fail -X POST -H "Content-Type:application/gzip" --upload-file $PACKAGE_FILE "https://uploads.github.com/repos/$INSTALLER_REPO/releases/$release_id/assets?name=$PACKAGE_NAME&access_token=$token")

echo "Received response $response"

echo "Done"
