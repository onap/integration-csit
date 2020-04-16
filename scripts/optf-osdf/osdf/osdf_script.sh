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

echo "### This is ${WORKSPACE}/scripts/optf-osdf/osdf/osdf_script.sh"
#
# add here whatever commands is needed to prepare the optf/osdf CSIT testing
#

# assume the base is /tmp dir
DIR=/tmp

# the directory of the script
echo ${DIR}
cd ${DIR}

# create directory for volume and copy configuration file
# run docker containers
OSDF_CONF=/tmp/osdf/properties/osdf_config.yaml
IMAGE_NAME=nexus3.onap.org:10003/onap/optf-osdf
IMAGE_VER=2.0.3-SNAPSHOT-latest

mkdir -p /tmp/osdf/properties
mkdir -p /tmp/sms/properties

cp ${WORKSPACE}/scripts/optf-osdf/osdf/osdf-properties/*.yaml /tmp/osdf/properties/.
cp ${WORKSPACE}/scripts/optf-osdf/osdf/osdf-properties/osdf.json /tmp/sms/properties/.

#change conductor/configdb simulator urls
OSDF_SIM_IP=`get-instance-ip.sh osdf_sim`
echo "OSDF_SIM_IP=${OSDF_SIM_IP}"
SMS_IP=`get-instance-ip.sh sms`
echo "SMS_IP=${SMS_IP}"

sed  -i -e "s%127.0.0.1:5000%${OSDF_SIM_IP}:5000%g" $OSDF_CONF
sed  -i -e "s%aaf-sms.onap:10443%${SMS_IP}:10443%g" $OSDF_CONF

#Preload secrets
docker exec --user root -i sms  /bin/sh -c "mkdir -p /preload/config"
docker cp /tmp/sms/properties/osdf.json sms:/preload/config/osdf.json
docker exec --user root -i sms  /bin/sh -c "/sms/bin/preload -cacert /sms/certs/aaf_root_ca.cer -jsondir /preload/config -serviceport 10443 -serviceurl http://localhost"

docker logs vault
docker run -d --name optf-osdf -v ${OSDF_CONF}:/opt/osdf/config/osdf_config.yaml -p "8698:8699" ${IMAGE_NAME}:${IMAGE_VER}

sleep 20

OSDF_IP=`get-instance-ip.sh optf-osdf`
${WORKSPACE}/scripts/optf-osdf/osdf/wait_for_port.sh ${OSDF_IP} 8699

echo "inspect docker things for tracing purpose"
docker inspect optf-osdf
