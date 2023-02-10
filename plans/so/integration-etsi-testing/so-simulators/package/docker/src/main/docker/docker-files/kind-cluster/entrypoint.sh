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
# Startup Docker daemon and wait for it to be ready.
echo "Running entrypoint-original.sh .."
/entrypoint-original.sh bash -c "touch /dockerd-ready && sleep infinity" &
while [ ! -f /dockerd-ready ]; do sleep 10; done
echo "Setting up KIND cluster"
# Startup a KIND cluster.
API_SERVER_ADDRESS=${API_SERVER_ADDRESS:-$(hostname -i)}
echo "hostname: ${API_SERVER_ADDRESS}"
sed -ri "s/^(\s*)(apiServerAddress\s*:\s*apiServerAddress\s*$)/\1apiServerAddress: ${API_SERVER_ADDRESS}/" kind-config.yaml
CERT_SANS=(${CERT_SANS:-""})
CERT_SANS+=(${API_SERVER_ADDRESS})
CERT_SANS+=($(hostname -i))
CERT_SANS+=(localhost)
CERT_SANS+=(127.0.0.1)
for node in $(kubectl get nodes -o wide --no-headers | awk '{print $6}'); do
echo "node: $node"
CERT_SANS+=(node)
done
UNIQUE_CERT_SANS=($(echo "${CERT_SANS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
for hostname in "${UNIQUE_CERT_SANS[@]}"; do
cat <<EOF >> kind-config.yaml
- group: kubeadm.k8s.io
  version: v1beta2
  kind: ClusterConfiguration
  patch: |
    - op: add
      path: /apiServer/certSANs/-
      value: ${hostname}
EOF
done
kind create cluster --config=kind-config.yaml --image=${KIND_NODE_IMAGE-"devopps/kind-node:v1.21.1"} --wait=900s
while read -r line;
do
  echo "$line";
done < "$HOME/.kube/config"
CONFIG_ADDRESS=$HOME/.kube/config

exec "$@"
