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
for version in ${VERSIONS} ; do
  supported_platform $CINC_IMAGE $version $arch || continue
  image="${CI_REGISTRY_IMAGE}/${CINC_IMAGE}:${version}-${arch}-${CI_COMMIT_SHORT_SHA}"
  docker pull ${image}
  id="$(docker run -it -d --rm --privileged ${image})"
  cinc-auditor detect -t docker://${id}
  cinc-auditor exec test/integration/${CINC_IMAGE}_spec.rb -t docker://${id}
  docker stop ${id}
done
