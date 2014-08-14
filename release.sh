#!/bin/bash
ORIGINAL_DIR=$(pwd)
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

set -o errexit
set -o nounset

OPTIND=1

no_push=

while getopts "x" opt; do
  case "$opt" in
    x)
      no_push=1
      ;;
  esac
done

shift "$((OPTIND-1))"
release=$1


cd $( dirname "${BASH_SOURCE[0]}" )

exit_invalid_release () {
  echo "$release: Not a valid release"
  exit 1
}

# We expect a release such as 1.1.1 or 1.2.3a1 or 2.0.0b2
echo "$release" | grep --silent --extended-regexp '^(\d+\.){2}\d([a-b]\d+)?$' || exit_invalid_release
final_release=$(echo "$release" | grep --only-matching --extended-regexp '^(\d+\.){2}\d')  # Chef does not support ax or bx in our release

exit_dirty_files () {
  echo "Dirty files in repo, aborting"
  exit 1
}
git diff-files --quiet || exit_dirty_files


# Valid release - start.
echo "Creating release $release"

echo "Creating release branch"
RELEASE_TAG="v$release"
RELEASE_BRANCH="release-$release"

make_local_release () {
  metadata_file="metadata.rb"
  install_file="scripts/install.py"

  sed -E -i '' "s/(version[ ]+)'[0-9.]*'/\1'$final_release'/g" $metadata_file
  sed -E -i '' "s/(DEFAULT_COOKBOOK_VERSION[ ]+=[ ]+)\"[0-9a-b.]*\"/\1\"$release\"/g" $install_file

  git checkout -b $RELEASE_BRANCH
  git add $metadata_file $install_file
  git commit -m "Release: $release"
  git tag $RELEASE_TAG HEAD
}

git tag | grep --extended-regexp "^${RELEASE_TAG}$" && {
  echo "Tag already exists. Deleting"
  git tag -d "$RELEASE_TAG"
}

git branch | grep --extended-regexp "${RELEASE_BRANCH}$" && {
  echo "Branch already exists. Deleting"
  git branch -D "$RELEASE_BRANCH"
}


make_local_release

RELEASE_DIR="$TMPDIR/installer-ng-release-$release-$$"
PACKAGE_NAME="package.tar.gz"
PACKAGE_FILE="$RELEASE_DIR/$PACKAGE_NAME"
RELEASE_PACKAGE_FILE=$RELEASE_DIR/installer-ng-${RELEASE_TAG}.tar.gz

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

cd $ORIGINAL_DIR

if [ -z "$no_push" ]; then
  echo "Pushing release branch"
  git push --force origin "${RELEASE_BRANCH}:${RELEASE_BRANCH}"
  echo "Pushing release tag"
  git push --force origin "refs/tags/${RELEASE_TAG}:refs/tags/${RELEASE_TAG}"
else
  echo "Not pushing release branch: -x is set"
fi

git checkout $ORIGINAL_BRANCH

echo "Done. Published: $release"

