#!/bin/bash
ORIGINAL_DIR=$(pwd)
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

set -o errexit
set -o pipefail
set -o nounset

OPTIND=1

VAR_SKIP_DIRTY_CHECK=0
VAR_SKIP_COOKBOOK_PACKAGE=0
VAR_SKIP_BUILD_PACKAGES=0
HAS_GVS=0
farm_gv=()  # List of Farms we want to set the INSTALLER_BRANCH GV on

warn_devel_arg () {
  echo "DO NOT RUN  THIS FOR A REAL RELEASE"
}

echo_usage () {
  echo 'Usage: build.sh [-x] [-s] [-f FARM_ID] <release>'
  echo '  -x: Skip the git dirty check'
  echo '  -s: Skip the cookbook package'
  echo '  -l: Skip the APT, RPM, and Python packages'
  echo '  -f: <deprecated for now>'
}


while getopts "hxslf:" opt
do
  case "$opt" in
    h)
      echo_usage
      exit 0
      ;;
    x)
      warn_devel_arg
      echo "Skipping dirty check"
      VAR_SKIP_DIRTY_CHECK=1
      ;;
    s)
      warn_devel_arg
      echo "Skipping cookbook package"
      VAR_SKIP_COOKBOOK_PACKAGE=1
      ;;
    l)
      warn_devel_arg
      echo "Skipping APT, RPM, and Python packages"
      VAR_SKIP_BUILD_PACKAGES=1
      ;;
    f)
      farm_gv+=("$OPTARG")
      HAS_GVS=1
      ;;
  esac
done

shift "$((OPTIND-1))"
if [[ "$#" -eq 0 ]]; then
  echo_usage
  echo 'Missing required positional argument: release'
  exit 1
fi
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

# Export these versions
export VERSION_FULL
export VERSION_PYTHON

# Chef will not accept a different release

is_final_release () {
  [[ "$VERSION_FINAL" = "$VERSION_FULL" ]]
}

skip_dirty_check () {
  [[ "$VAR_SKIP_DIRTY_CHECK" = 1 ]]
}

skip_cookbook_package () {
  [[ "$VAR_SKIP_COOKBOOK_PACKAGE" = 1 ]]
}

skip_build_packages () {
  [[ "$VAR_SKIP_BUILD_PACKAGES" = 1 ]]
}

if is_final_release; then
  if skip_dirty_check; then
    echo "You may not skip the dirty check for a final release"
    exit 1
  fi
  if skip_cookbook_package; then
    echo "You may not skip the cookbook package for a final release"
    exit 1
  fi
  if skip_build_packages; then
    echo "You may not skip the APT, RPM, and Python packages for a final release"
    exit 1
  fi
fi


exit_dirty_files () {
  if skip_dirty_check; then
    return 0
  fi

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
sed=$(which gsed || true)
if [[ -z "$sed" ]]; then
  sed="sed"
fi

$sed --version | grep --silent "GNU sed" || {
  echo "You must install GNU sed !"
}

# First, test!
bundle exec rspec

make_git_release () {
  metadata_file="metadata.rb"
  wrapper_version_file="wrapper/scalr-manage/scalr_manage/version.py"

  sed_opts="-E -i"
  $sed $sed_opts "s/(version[ ]+)'[0-9.]*'/\1'${VERSION_FINAL}'/g" "${metadata_file}"
  $sed $sed_opts "s/(__version__[ ]*=[ ]*)\"[0-9a-b.]*\"/\1\"${VERSION_PYTHON}\"/g" "${wrapper_version_file}"
  $sed $sed_opts "s/(__pkg_version__[ ]*=[ ]*)\"[0-9a-b.]*\"/\1\"${VERSION_FULL}\"/g" "${wrapper_version_file}"

  git tag | grep --extended-regexp "^${RELEASE_TAG}$" && {
    echo "Tag already exists. Deleting"
    git tag -d "$RELEASE_TAG"
  }

  git branch | grep --extended-regexp "${RELEASE_BRANCH}$" && {
    echo "Branch already exists. Deleting"
    git branch -D "$RELEASE_BRANCH"
  }

  git checkout -b $RELEASE_BRANCH
  git add $metadata_file $wrapper_version_file
  git commit -m "Release: $VERSION_FULL"
  git tag $RELEASE_TAG HEAD
}

make_git_release

make_cookbook_package () {
  if skip_cookbook_package; then
    return 0
  fi

  if [[ -z "${TMPDIR}" ]]; then
    echo "No tmp dir - aborting"
    exit 1
  fi

  RELEASE_DIR="$TMPDIR/installer-ng-release-$VERSION_FULL-$$"
  PACKAGE_NAME="package.tar.gz"
  PACKAGE_FILE="$RELEASE_DIR/$PACKAGE_NAME"
  RELEASE_PACKAGE_FILE=$RELEASE_DIR/installer-ng-${RELEASE_TAG}.tar.gz

  echo "Releasing in $RELEASE_DIR"
  git clone . $RELEASE_DIR
  CLEANUP_RM_DIRS="$CLEANUP_RM_DIRS $RELEASE_DIR"

  echo "Cleaning up build dir"
  rm -rf "$RELEASE_DIR/.git"
  rm -rf "$RELEASE_DIR/wrapper"


  echo "Creating release package"
  cd $RELEASE_DIR
  berks package "$PACKAGE_FILE"

  echo "Creating boto configuration file"  # TODO - This might compromise usability here
  export BOTO_CONFIG="${RELEASE_DIR}/boto.cfg"
  echo "[s3]" > "${BOTO_CONFIG}"
  echo "calling_format = boto.s3.connection.OrdinaryCallingFormat" >> "${BOTO_CONFIG}"

  # Upload the release in S3
  echo "Uploading to S3"
  mv $PACKAGE_FILE $RELEASE_PACKAGE_FILE
  s3put --bucket=installer.scalr.com --prefix=$(dirname $RELEASE_PACKAGE_FILE) --key_prefix="releases" --grant=public-read --callback=10 $RELEASE_PACKAGE_FILE
}

make_cookbook_package

make_build_packages () {
  if skip_build_packages; then
    return 0
  fi

  # Build the wrapper packages
  echo "Building wrapper packages"
  $HERE/wrapper/build/build.sh
}

make_build_packages


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



if [[ "${HAS_GVS}" = "1" ]]; then
  # Set the GVs as requested
  BRANCH_VAR="INSTALLER_BRANCH"

  for farm in "${farm_gv[@]}"
  do
    echo "Setting '$BRANCH_VAR' = '$RELEASE_BRANCH' on '$farm'"
    args="--param-name=$BRANCH_VAR --param-value=$RELEASE_BRANCH --farm-id=$farm"

    # There is a typo in the method name at this time, so we need to find the right name
    method=$(scalr help  | grep -E 'set-.*-variable')
    scalr $method $args
  done
fi
