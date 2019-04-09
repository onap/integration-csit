#!/bin/bash
#
# -------------------------------------------------------------------------
#   Copyright (c) 2018 AT&T Intellectual Property
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# -------------------------------------------------------------------------
#

echo "This is ${WORKSPACE}/scripts/optf-cmso/cmso/kill_and_remove_cmso_containers.sh"
cd $WORKSPACE/archives/cmso-clone
cd cmso/cmso-robot/docker/cmso-service
docker-compose down

cp -f ./cmso-robot/logs/output.xml $WORKSPACE/archives
cp -f ./cmso-robot/logs/log.html $WORKSPACE/archives
cp -f ./cmso-robot/logs/report.html $WORKSPACE/archives
rm -rf ${WORKSPACE}/archives/cmso-clone


