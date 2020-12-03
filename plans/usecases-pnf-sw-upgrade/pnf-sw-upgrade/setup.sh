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


SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PARENT=usecases-pnf-sw-upgrade
export SUB_PARENT=pnf-sw-upgrade
source ${WORKSPACE}/plans/$PARENT/$SUB_PARENT/test.properties
export $PROJECT_NAME
export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

if [ "$MTU" == "" ]; then
	  export MTU="1450"
fi
unset http_proxy https_proxy

# Prepare Environment
echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

HOST_IP_ADDR=localhost

###################### setup so ##############################
source $SO_DOCKER_PATH/so_setup.sh

###################### setup sdnc ############################
source $SDNC_DOCKER_PATH/sdn_setup.sh

###################### setup cds #############################
source $CDS_DOCKER_PATH/cds_setup.sh

###################### setup pnfsim ##########################
docker-compose -f $PNF_SIM_DOCKER_PATH/docker-compose.yml -p $PROJECT_NAME up -d 

##### update pnf simulator ip in config deploy request #######
RES_KEY=$(uuidgen -r)
sed -i "s/pnfaddr/$LOCAL_IP/g" $REQUEST_DATA_PATH/mount.json
sed -i "s/pnfaddr/$LOCAL_IP/g" $REQUEST_DATA_PATH/mount2.json

##############################################################

echo "sleeping for 30 sec"
sleep 30

REPO_IP='127.0.0.1'
ROBOT_VARIABLES+=" -v REPO_IP:${REPO_IP} "
ROBOT_VARIABLES+=" -v SCRIPTS:${SCRIPTS} "


echo "Finished executing setup for pnf-sw-upgrade"