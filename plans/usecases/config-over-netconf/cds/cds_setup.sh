#!/bin/bash
#
# ============LICENSE_START=======================================================
#   Copyright (C) 2019 Nordix Foundation.
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
export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
unset http_proxy https_proxy

#cd $WORKSPACE/archives/cds/ms/blueprintsprocessor/distribution/src/main/dc/

############# update ip of sdnc in docker-compose###########
SDNC_CONTAINER=$(docker ps -a -q --filter="name=sdnc_controller_container")
SDNC_CONTAINER_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDNC_CONTAINER)
echo " " >> docker-compose.yaml
echo "    extra_hosts:"  >> docker-compose.yaml
echo "    - 'sdnc:$LOCAL_IP'" >> docker-compose.yaml
#############################################################

docker-compose up -d
sleep 10
################# Check state of BP ####################
BP_CONTAINER=$(docker ps -a -q --filter="name=bp-rest")
CCSDK_MARIADB=$(docker ps -a -q --filter="name=ccsdk-mariadb")
for i in {1..10}; do
if [ $(docker inspect --format='{{ .State.Running }}' $BP_CONTAINER) ] && \
[ $(docker inspect --format='{{ .State.Running }}' $CCSDK_MARIADB) ]
then
   echo "Blueprint proc Service Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

