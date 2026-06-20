#!/bin/sh
#
# Author:: Lance Albertson <lance@osuosl.org>
# Copyright:: Copyright 2026, Cinc Project
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
#
# Append a native remote buildx builder node for an architecture. If that node
# is unreachable (e.g. offline for maintenance), fall back to building the arch
# locally via QEMU emulation so the pipeline still passes. binfmt is registered
# before the local buildkit boots (at bake time), so the amd64 node then
# advertises the emulated platform and buildx routes to it; native remote nodes
# remain preferred whenever they are reachable.
#
# Requires $BUILDER_NAME in the environment (set in .gitlab-ci.yml).
#
# Usage: append-builder.sh <context> <ssh-host> <platform> <binfmt-arch>
set -e

ctx="$1"
host="$2"
platform="$3"
emulation_arch="$4"

docker context create "$ctx" --docker "host=ssh://${host}" >/dev/null 2>&1 || true

if docker buildx create --name "$BUILDER_NAME" --append "$ctx" --platform "$platform" --config buildkitd.toml; then
  echo "append-builder: using native node '${ctx}' for ${platform}"
else
  echo "append-builder: WARNING node '${ctx}' (${host}) unavailable; falling back to QEMU emulation for ${platform}"
  docker context rm -f "$ctx" >/dev/null 2>&1 || true
  docker run --privileged --rm tonistiigi/binfmt --install "$emulation_arch"
fi
