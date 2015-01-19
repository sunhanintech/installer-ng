#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset


REL_HERE=$(dirname "${BASH_SOURCE}")
HERE=$(cd "${REL_HERE}"; pwd)  # Get an absolute path

FACTORY_REPO=scalr/factory

# Start building
cd $HERE  # TODO - Needed?

parallelCommands=()
imgs=()

for distroDir in *; do
  releases="${distroDir}/RELEASES"
  if [[ ! -f "$releases" ]]; then
    echo "$distroDir: does not look like a build tree"
    continue
  fi

  for release in $(cat $releases); do
    echo "Found release for ${distroDir}: ${release}"
    img="${FACTORY_REPO}:${distroDir}-${release}"
    parallelCommands+=("${HERE}/build_one.sh ${img} ${distroDir} ${release}")
    imgs+=("${img}")
  done
done

# Not useful to pull multiple in parallel,
echo "Pulling existing images."
for img in "${imgs[@]}"; do
  docker pull "${img}"
done

echo "Building images in parallel. This may take a while..."
parallel --no-notice --env VERSION_FULL ::: "${parallelCommands[@]}"

# Images shouldn't be pushed in parallel (they're all in the same repo)
echo "Pushing updated images."
for img in "${imgs[@]}"; do
  docker push "${img}"
done
