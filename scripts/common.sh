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
declare -A platforms

platforms[docker-auditor:4.18.111:aarch64]=1
platforms[docker-auditor:4.18.111:x86_64]=1
platforms[omnibus-centos:6:x86_64]=1
platforms[omnibus-centos:7:aarch64]=1
platforms[omnibus-centos:7:x86_66]=1
platforms[omnibus-centos:8:aarch64]=1
platforms[omnibus-centos:8:x86_64]=1
platforms[omnibus-debian:10:aarch64]=1
platforms[omnibus-debian:10:x86_64]=1
platforms[omnibus-debian:8:x86_64]=1
platforms[omnibus-debian:9:x86_64]=1
platforms[omnibus-opensuse:15:aarch64]=1
platforms[omnibus-opensuse:15:x86_64]=1
platforms[omnibus-ubuntu:16.04:x86_64]=1
platforms[omnibus-ubuntu:18.04:aarch64]=1
platforms[omnibus-ubuntu:18.04:x86_64]=1
platforms[omnibus-ubuntu:20.04:aarch64]=1
platforms[omnibus-ubuntu:20.04:x86_64]=1

supported_platform() {
  local image=$1 version=$2 arch=$3
  [[ -v platforms[${image}:${version}:${arch}] ]] && return 0
}
