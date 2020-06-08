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
source scripts/common.sh
set -ex
arch="$(uname -m)"
if [ -e ${CINC_IMAGE}/Dockerfile.${arch} ] ; then
  docker_file="${CINC_IMAGE}/Dockerfile.${arch}"
else
  docker_file="${CINC_IMAGE}/Dockerfile"
fi
for version in ${VERSIONS} ; do
  supported_platform $CINC_IMAGE $version $arch || continue
  image="${CI_REGISTRY_IMAGE}/${CINC_IMAGE}:${version}-${arch}-${CI_COMMIT_SHORT_SHA}"
  opts=""
  if [ -n "$(get_jdk $CINC_IMAGE $version)" ] ; then
    opts="--build-arg JDK_VER=$(get_jdk $CINC_IMAGE $version)"
  fi
  docker build --no-cache --build-arg VERSION="${version}" -t ${image} -f ${docker_file} ${opts} ${CINC_IMAGE}
  docker push ${image}
done
