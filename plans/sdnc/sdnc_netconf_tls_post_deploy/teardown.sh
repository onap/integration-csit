#!/bin/bash
#
# Copyright 2017 ZTE, Inc. and others.
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

docker-compose -f "${SCRIPTS}"/sdnc/certservice/docker-compose.yml down -v
docker-compose -f "${SCRIPTS}"/sdnc/sdnc/docker-compose.yml down -v
docker-compose -f "${SCRIPTS}"/sdnc/netconf-pnp-simulator/docker-compose.yml down -v

make clear -C "${WORKSPACE}"/plans/sdnc/sdnc_netconf_tls_post_deploy/certs

rm -rf "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/tmp
rm -rf "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/certs
rm -rf "${WORKSPACE}"/tests/sdnc/sdnc_netconf_tls_post_deploy/cert-data