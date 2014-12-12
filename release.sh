#!/bin/bash
ORIGINAL_DIR=$(pwd)
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

set -o errexit
set -o nounset

OPTIND=1

farm_gv=()  # List of Farms we want to set the INSTALLER_BRANCH GV on

while getopts "xf:" opt
do
  case "$opt" in
    f)
      farm_gv+=("$OPTARG")
      ;;
  esac
done

shift "$((OPTIND-1))"
VERSION_FULL=$1


HERE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
cd $HERE

exit_invalid_release () {
  echo "$VERSION_FULL: Not a valid release"
  exit 1
}

# Load the version into the environment. This will cause us to exit if the version is invalid,
# so we don't need further validation.
eval $(./version_helper.py "$VERSION_FULL")

# Export this one too
export VERSION_FULL

# Chef will not accept a different release

is_final_release () {
  [[ "$VERSION_FINAL" = "$VERSION_FULL" ]]
}

exit_dirty_files () {
  echo "Dirty files in repo, aborting"
  exit 1
}
git diff-files --quiet || exit_dirty_files


# Valid release - start.
CLEANUP_RM_DIRS=""
cleanup () {
  echo "Exiting -- cleaning up"

  rm -rf -- $CLEANUP_RM_DIRS

  cd "${HERE}"
  git checkout $ORIGINAL_BRANCH
}

trap "cleanup" EXIT

echo "Creating release $VERSION_FULL"

echo "Creating release branch"
RELEASE_TAG="v$VERSION_FULL"
RELEASE_BRANCH="release-$VERSION_FULL"


# Support both GNU sed and OSX sed
SED_OPTS="-E -i"
sed --version | grep --silent "GNU sed" || SED_OPTS="$SED_OPTS ''"

make_local_release () {
  metadata_file="metadata.rb"
  wrapper_version_file="wrapper/scalr-manage/scalr_manage/version.py"
  install_file="scripts/install.py"

  sed $SED_OPTS "s/(version[ ]+)'[0-9.]*'/\1'$VERSION_FINAL'/g" $metadata_file
  sed $SED_OPTS "s/(__version__[ ]*=[ ]*)\"[0-9a-b.]*\"/\1\"$VERSION_FULL\"/g" $wrapper_version_file
  sed $SED_OPTS "s/(DEFAULT_COOKBOOK_RELEASE[ ]+=[ ]+)\"[0-9a-b.]*\"/\1\"$VERSION_FULL\"/g" $install_file

  git checkout -b $RELEASE_BRANCH
  git add $metadata_file $wrapper_version_file $install_file
  git commit -m "Release: $VERSION_FULL"
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

RELEASE_DIR="$TMPDIR/installer-ng-release-$VERSION_FULL-$$"
PACKAGE_NAME="package.tar.gz"
PACKAGE_FILE="$RELEASE_DIR/$PACKAGE_NAME"
RELEASE_PACKAGE_FILE=$RELEASE_DIR/installer-ng-${RELEASE_TAG}.tar.gz

echo "Releasing in $RELEASE_DIR"
if [ -z $RELEASE_DIR ]; then
  echo "No tmp dir - aborting"
  exit 1
fi
git clone . $RELEASE_DIR
CLEANUP_RM_DIRS="$CLEANUP_RM_DIRS $RELEASE_DIR"

echo "Cleaning up build dir"
rm -rf "$RELEASE_DIR/.git"
rm -rf "$RELEASE_DIR/wrapper"


echo "Creating release package"
cd $RELEASE_DIR
berks package "$PACKAGE_FILE"

# Upload the release in S3
echo "Uploading to S3"
mv $PACKAGE_FILE $RELEASE_PACKAGE_FILE
s3put --bucket=installer.scalr.com --prefix=$(dirname $RELEASE_PACKAGE_FILE) --key_prefix="releases" --grant=public-read --callback=10 $RELEASE_PACKAGE_FILE

# Build the wrapper packages
echo "Building wrapper packages"
$HERE/wrapper/build/build.sh

cd $ORIGINAL_DIR

if is_final_release; then
  echo "Pushing release branch"
  git push --force origin "${RELEASE_BRANCH}:${RELEASE_BRANCH}"
  echo "Pushing release tag"
  git push --force origin "refs/tags/${RELEASE_TAG}:refs/tags/${RELEASE_TAG}"
else
  echo "Not pushing release branch: $VERSION_FULL is not a final release"
fi

echo "Done. Published: $VERSION_FULL"


# Now, set the GVs as requested
BRANCH_VAR="INSTALLER_BRANCH"

for farm in "${farm_gv[@]}"
do
  echo "Setting '$BRANCH_VAR' = '$RELEASE_BRANCH' on '$farm'"
  args="--param-name=$BRANCH_VAR --param-value=$RELEASE_BRANCH --farm-id=$farm"

  # There is a typo in the method name at this time, so we need to find the right name
  method=$(scalr help  | grep -E 'set-.*-variable')
  scalr $method $args
done
