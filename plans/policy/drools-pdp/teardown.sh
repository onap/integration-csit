#!/bin/bash
#
# Copyright 2017-2020 AT&T Intellectual Property. All rights reserved.
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

mkdir -p $WORKSPACE/archives/

docker exec -it drools bash -c '/opt/app/policy/bin/features status' > $WORKSPACE/archives/drools-apps-features.log
docker exec -it drools bash -c "cat /var/log/onap/policy/pdpd/error.log" > $WORKSPACE/archives/drools-error.log
docker exec -it drools bash -c "cat /var/log/onap/policy/pdpd/network.log" > $WORKSPACE/archives/drools-network.log

docker logs drools > ${WORKSPACE}/archives/drools.log
docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-drools.yml logs > $WORKSPACE/archives/docker-compose-drools.log

docker-compose -f ${WORKSPACE}/scripts/policy/docker-compose-drools.yml down -v
