#!/bin/bash
#
# Author:: Lance Albertson <lance@osuosl.org>
# Copyright:: Copyright 2020, Cinc Project
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
mkdir -p ~/.docker
echo '{"experimental":"enabled"}' > ~/.docker/config.json
cat << EOF > /tmp/docker-token
$DOCKER_TOKEN
EOF
cat /tmp/docker-token | docker login --username $DOCKER_USERNAME --password-stdin
rm -rf /tmp/docker-token
# Enable experimental features to allow manifest command

LATEST=0
# Find the newest version and use that to tag latest
for i in $VERSIONS ; do
  if (( $(echo "$i > $LATEST" | bc -l) )) ; then
    LATEST=$i
  fi
done

if [ "$LATEST" -eq "0" ] ; then
  echo "Could not find highest version available"
  exit 1
fi

set -ex

for version in ${VERSIONS} ; do
  # Declare dynamic variable
  for arch in ${ARCHS} ; do
    declare "${arch}_image=cincproject/${CINC_IMAGE}:${version}-${arch}"
  done

  release_image="cincproject/${CINC_IMAGE}:${version}"
  [ -n "${x86_64_image}" ] && docker pull ${x86_64_image}
  [ -n "${aarch64_image}" ] && docker pull ${aarch64_image}
  [ -n "${ppc64le_image}" ] && docker pull ${ppc64le_image}
  docker manifest create ${release_image} ${x86_64_image} ${aarch64_image} ${ppc64le_image}
  [ -n "${aarch64_image}" ] && docker manifest annotate ${release_image} ${aarch64_image} --arch arm64
  [ -n "${ppc64le_image}" ] && docker manifest annotate ${release_image} ${ppc64le_image} --arch ppc64le
  docker manifest inspect ${release_image}
  docker manifest push ${release_image}
done

# Declare dynamic variable
for arch in ${ARCHS} ; do
  declare "${arch}_image=cincproject/${CINC_IMAGE}:${LATEST}-${arch}"
done

# Create latest tag
release_image="cincproject/${CINC_IMAGE}:latest"
docker manifest create ${release_image} ${x86_64_image} ${aarch64_image} ${ppc64le_image}
[ -n "${aarch64_image}" ] && docker manifest annotate ${release_image} ${aarch64_image} --arch arm64
[ -n "${ppc64le_image}" ] && docker manifest annotate ${release_image} ${ppc64le_image} --arch ppc64le
docker manifest inspect ${release_image}
docker manifest push ${release_image}
