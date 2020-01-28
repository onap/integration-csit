#!/usr/bin/env bash
#
# ============LICENSE_START=======================================================
#  Copyright (C) 2019 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END======================================================
#

echo "Running AAF setup.sh"
bash ../aafapi/setup.sh
docker stop aaf-fs
sleep 10

echo "Starting up EJBCA Server"
echo  "  Getting EJBCA-CA Image   "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
IMAGE='primekey/ejbca-ce'
docker pull $IMAGE
IMAGEID=$(docker images primekey/ejbca-ce --format "{{.ID}}")
echo "Image ID of primekey/ejbca-ce is : " $IMAGEID
echo
echo

echo  "  Run the Container  "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
IMAGE='primekey/ejbca-ce'
echo $d
echo "Running the container in the background"
docker run -it --rm -d -p 80:8080 -p 443:8443 -h mycahostname --name ejbcaserver $IMAGE
echo " "
echo $d
echo "...... waiting 30 seconds ...... "
sleep 30

echo "  Running EJBCA Commands "
echo ---------------------------------------------------------------------------------------------------------------------
echo -e "\033[0m"
docker ps
MYCONTAINER=$(docker ps -aqf "name=ejbcaserver")
echo CONTAINER ID of primekey/ejbca-ce is : = $MYCONTAINER
docker exec $MYCONTAINER ejbca.sh config cmp addalias --alias cmp
docker exec $MYCONTAINER ejbca.sh config cmp updatealias --alias cmp --key allowautomatickeyupdate --value true
docker exec $MYCONTAINER ejbca.sh config cmp dumpalias --alias cmp
docker exec $MYCONTAINER ejbca.sh ra addendentity --username node123 --dn "CN=Node123" --caname ManagementCA --password mypassword --type 1 --token USERGENERATED
docker exec $MYCONTAINER ejbca.sh ra setclearpwd --username node123 --password mypassword
sleep 20
