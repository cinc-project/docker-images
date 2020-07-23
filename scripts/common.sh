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
declare -A jdk_ver

platforms[docker-auditor:4.22.0:aarch64]=1
platforms[docker-auditor:4.22.0:x86_64]=1
platforms[docker-auditor:4.22.0:ppc64le]=1
platforms[omnibus-amazonlinux:2:aarch64]=1
platforms[omnibus-amazonlinux:2:x86_64]=1
platforms[omnibus-centos:6:x86_64]=1
platforms[omnibus-centos:7:aarch64]=1
platforms[omnibus-centos:7:x86_64]=1
platforms[omnibus-centos:8:aarch64]=1
platforms[omnibus-centos:8:x86_64]=1
platforms[omnibus-debian:8:x86_64]=1
platforms[omnibus-debian:9:x86_64]=1
platforms[omnibus-debian:10:aarch64]=1
platforms[omnibus-debian:10:x86_64]=1
platforms[omnibus-opensuse:15:aarch64]=1
platforms[omnibus-opensuse:15:x86_64]=1
platforms[omnibus-ubuntu:16.04:x86_64]=1
platforms[omnibus-ubuntu:18.04:aarch64]=1
platforms[omnibus-ubuntu:18.04:x86_64]=1
platforms[omnibus-ubuntu:20.04:aarch64]=1
platforms[omnibus-ubuntu:20.04:x86_64]=1

jdk_ver[omnibus-amazonlinux:2]="11"
jdk_ver[omnibus-centos:6]="1.8.0"
jdk_ver[omnibus-centos:7]="11"
jdk_ver[omnibus-centos:8]="11"
jdk_ver[omnibus-debian:8]="7"
jdk_ver[omnibus-debian:9]="8"
jdk_ver[omnibus-debian:10]="11"
jdk_ver[omnibus-opensuse:15]="11"
jdk_ver[omnibus-ubuntu:16.04]="9"
jdk_ver[omnibus-ubuntu:18.04]="11"
jdk_ver[omnibus-ubuntu:20.04]="14"

get_jdk() {
  local image=$1 version=$2
  echo ${jdk_ver[${image}:${version}]}
}

supported_platform() {
  local image=$1 version=$2 arch=$3
  [[ -v platforms[${image}:${version}:${arch}] ]] && return 0
}
