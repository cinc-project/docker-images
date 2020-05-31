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
set -e

REPO_ID="$(curl -f -s --header "PRIVATE-TOKEN: ${DEPLOY_TOKEN}" \
  "https://gitlab.com/api/v4/projects/${CI_PROJECT_ID}/registry/repositories" | \
  jq -r --arg repo "${CINC_IMAGE}" '.[]? | select(.name == $repo) | .id')"

for version in ${VERSIONS} ; do
  for arch in ${ARCHS} ; do
    supported_platform $CINC_IMAGE $version $arch || continue
    tag="${version}-${arch}-${CI_COMMIT_SHORT_SHA}"
    echo -n "Deleting ${CINC_IMAGE}:${tag} ... "
    url="https://gitlab.com/api/v4/projects/${CI_PROJECT_ID}/registry/repositories/${REPO_ID}/tags/${tag}"
    curl -f -s --request DELETE --header "PRIVATE-TOKEN: ${DEPLOY_TOKEN}" ${url}
    echo
  done
done
