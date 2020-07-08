#!/bin/bash
#
# Copyright 2019 © Samsung Electronics Co., Ltd.
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

#
# Note! This is only temporary solution for killing SDC DCAE plugin's
# docker containers that must be currently used whenever docker_run.sh is used
# with -dcae option - See SDC-2338 for related image naming issue
#
# DCAE plugin-related parts will also have to be refactored under dedicated
# directories in the future
#

echo "This is ${WORKSPACE}/scripts/sdc-dcae-d/cleanup_sdc_workflow.sh"

cp -rf ${WORKSPACE}/data/logs/ ${WORKSPACE}/archives/

ls -Rt ${WORKSPACE}/archives/

#kill and remove all sdc dockers
docker stop $(docker ps -a -q --filter="name=sdc")
docker rm $(docker ps -a -q --filter="name=sdc")
# kill and remove all sdc dcae dockers
docker stop workflow-frontend
docker stop workflow-backend
docker rm workflow-frontend
docker rm workflow-backend

#delete data folder

sudo rm -rf ${WORKSPACE}/data/*