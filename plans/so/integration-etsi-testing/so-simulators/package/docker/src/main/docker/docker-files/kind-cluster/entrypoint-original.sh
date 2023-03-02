#!/bin/bash
# ============LICENSE_START=======================================================
#   Copyright (C) 2023 Nordix Foundation.
# ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# Script copied from https://hub.docker.com/r/devopps/kind-cluster-buster

set -o errexit
set -o nounset
set -o pipefail

# This is copied from official dind script:
# https://raw.githubusercontent.com/docker/docker/master/hack/dind
if [ -d /sys/kernel/security ] && ! mountpoint -q /sys/kernel/security; then
    mount -t securityfs none /sys/kernel/security || {
        echo >&2 'Could not mount /sys/kernel/security.'
        echo >&2 'AppArmor detection and --privileged mode might break.'
    }
fi

# Mount /tmp (conditionally)
if ! mountpoint -q /tmp; then
    mount -t tmpfs none /tmp
fi

# Check cgroupfs.
# Verify the filesystem.
if [ ! -d /sys/fs/cgroup/ ]; then
    echo >&2 'ERROR: Cgroupfs is not mounted'
    exit 1
fi

# Determine cgroup parent for docker daemon.
# We need to make sure cgroups created by the docker daemon do not
# interfere with other cgroups on the host, and do not leak after this
# container is terminated.
if [ -f /sys/fs/cgroup/systemd/release_agent ]; then
  # This means the user has bind mounted host /sys/fs/cgroup to the
  # same location in the container (e.g., using the following docker
  # run flags: `-v /sys/fs/cgroup:/sys/fs/cgroup`). In this case, we
  # need to make sure the docker daemon in the container does not
  # pollute the host cgroups hierarchy.
  # Note that `release_agent` file is only created at the root of a
  # cgroup hierarchy.
  CGROUP_PARENT="$(grep systemd /proc/self/cgroup | cut -d: -f3)/docker"
else
  CGROUP_PARENT="/docker"
  # For each cgroup subsystem, Docker does a bind mount from the
  # current cgroup to the root of the cgroup subsystem. For instance:
  #   /sys/fs/cgroup/memory/docker/<cid> -> /sys/fs/cgroup/memory
  #
  # This will confuse some system software that manipulate cgroups
  # (e.g., kubelet/cadvisor, etc.) sometimes because
  # `/proc/<pid>/cgroup` is not affected by the bind mount. The
  # following is a workaround to recreate the original cgroup
  # environment by doing another bind mount for each subsystem.
  CURRENT_CGROUP=$(grep systemd /proc/self/cgroup | cut -d: -f3)
  CGROUP_SUBSYSTEMS=$(findmnt -lun -o source,target -t cgroup | grep "${CURRENT_CGROUP}" | awk '{print $2}')
  
  echo "${CGROUP_SUBSYSTEMS}" |
  while IFS= read -r SUBSYSTEM; do
    mkdir -p "${SUBSYSTEM}${CURRENT_CGROUP}"
    mount --bind "${SUBSYSTEM}" "${SUBSYSTEM}${CURRENT_CGROUP}"
  done
fi

setsid dockerd \
  --cgroup-parent="${CGROUP_PARENT}" \
  --bip="${DOCKERD_BIP:-172.17.1.1/24}" \
  --mtu="${DOCKERD_MTU:-1400}" \
  --raw-logs \
  ${DOCKER_ARGS:-} >/var/log/docker/dockerd.log 2>&1 &
  
# Wait until dockerd is ready.
until docker ps >/dev/null 2>&1
do
  echo "Waiting for dockerd..."
  sleep 1
done

exec "$@"
