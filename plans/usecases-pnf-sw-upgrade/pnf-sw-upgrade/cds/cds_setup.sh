#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2020 Nordix Foundation.
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

# @author Rahul Tyagi (rahul.tyagi@est.tech)

CDS_DATA_PATH=$WORKSPACE/plans/$PARENT/$SUB_PARENT/cds

cd $CDS_DATA_PATH
export CDS_DOCKER_PATH=$CDS_DOCKER_PATH
export APP_CONFIG_HOME=$APP_CONFIG_HOME

docker pull $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$BP_IMAGE_TAG
docker tag $NEXUS_DOCKER_REPO/onap/ccsdk-blueprintsprocessor:$BP_IMAGE_TAG onap/ccsdk-blueprintsprocessor:latest

docker-compose -f $CDS_DATA_PATH/docker-compose.yml -p $PROJECT_NAME up -d 
sleep 10
################# Check state of BP ####################
BP_CONTAINER=$(docker ps -a -q --filter="name=bp-rest")
CCSDK_MARIADB=$(docker ps -a -q --filter="name=ccsdk-mariadb")
for i in {1..10}; do
if [ $(docker inspect --format='{{ .State.Running }}' $BP_CONTAINER) ]
then
   echo "Blueprint proc Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

