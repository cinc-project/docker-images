#!/bin/bash
#
# Author:: Lance Albertson <lance@osuosl.org>
# Copyright:: Copyright 2020-2022, Cinc Project
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

platforms[docker-auditor:5.22.3:aarch64]=1
platforms[docker-auditor:5.22.3:ppc64le]=1
platforms[docker-auditor:5.22.3:s390x]=1
platforms[docker-auditor:5.22.3:x86_64]=1
platforms[omnibus-almalinux:8:aarch64]=1
platforms[omnibus-almalinux:8:ppc64le]=1
platforms[omnibus-almalinux:8:s390x]=1
platforms[omnibus-almalinux:8:x86_64]=1
platforms[omnibus-almalinux:9:aarch64]=1
platforms[omnibus-almalinux:9:ppc64le]=1
platforms[omnibus-almalinux:9:s390x]=1
platforms[omnibus-almalinux:9:x86_64]=1
platforms[omnibus-amazonlinux:2:aarch64]=1
platforms[omnibus-amazonlinux:2:x86_64]=1
platforms[omnibus-amazonlinux:2022:x86_64]=1
platforms[omnibus-amazonlinux:2023:aarch64]=1
platforms[omnibus-amazonlinux:2023:x86_64]=1
platforms[omnibus-centos:7:aarch64]=1
platforms[omnibus-centos:7:ppc64le]=1
platforms[omnibus-centos:7:x86_64]=1
platforms[omnibus-centos-stream:8:aarch64]=1
platforms[omnibus-centos-stream:8:ppc64le]=1
platforms[omnibus-centos-stream:8:x86_64]=1
platforms[omnibus-centos-stream:9:aarch64]=1
platforms[omnibus-centos-stream:9:ppc64le]=1
platforms[omnibus-centos-stream:9:x86_64]=1
platforms[omnibus-debian:10:aarch64]=1
platforms[omnibus-debian:10:x86_64]=1
platforms[omnibus-debian:11:aarch64]=1
platforms[omnibus-debian:11:x86_64]=1
platforms[omnibus-debian:12:aarch64]=1
platforms[omnibus-debian:12:x86_64]=1
platforms[omnibus-opensuse:15.2:aarch64]=1
platforms[omnibus-opensuse:15.2:x86_64]=1
platforms[omnibus-rockylinux:8:aarch64]=1
platforms[omnibus-rockylinux:8:x86_64]=1
platforms[omnibus-rockylinux:9:aarch64]=1
platforms[omnibus-rockylinux:9:x86_64]=1
platforms[omnibus-ubuntu:18.04:aarch64]=1
platforms[omnibus-ubuntu:18.04:x86_64]=1
platforms[omnibus-ubuntu:20.04:aarch64]=1
platforms[omnibus-ubuntu:20.04:x86_64]=1
platforms[omnibus-ubuntu:22.04:aarch64]=1
platforms[omnibus-ubuntu:22.04:x86_64]=1
platforms[vagrant-virtualbox:20230317:x86_64]=1

supported_platform() {
  local image=$1 version=$2 arch=$3
  [[ -v platforms[${image}:${version}:${arch}] ]] && return 0
}
