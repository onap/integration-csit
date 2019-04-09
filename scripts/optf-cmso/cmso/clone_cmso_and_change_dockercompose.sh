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


echo "This is ${WORKSPACE}/scripts/cmso/clone_cmso_and_change_dockercompose.sh"




# Clone cmso repo to get extra folder that has all needed to run docker with docker-compose to start DB and cmso-service and cmso-dbinit
mkdir -p $WORKSPACE/archives/cmso-clone
cd $WORKSPACE/archives/cmso-clone
git clone --depth 1 https://gerrit.onap.org/r/optf/cmso -b master
cd cmso/cmso-robot/docker/cmso-service

sed -i '/image: onap\/optf-cmso-service/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-service:latest' docker-compose.yml
sed -i '/image: onap\/optf-cmso-dbinit/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-dbinit:latest' docker-compose.yml
sed -i '/image: onap\/optf-cmso-topology/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-topology:latest' docker-compose.yml
sed -i '/image: onap\/optf-cmso-ticketmgt/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-ticketmgt:latest' docker-compose.yml
sed -i '/image: onap\/optf-cmso-optimizer/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-optimizer:latest' docker-compose.yml
sed -i '/image: onap\/optf-cmso-robot/c\    image: nexus3.onap.org:10001\/onap\/optf-cmso-robot:latest' docker-compose.yml


#!/bin/bash
docker-compose up >up.txt 2>&1 &

### Wait for robot to finish
sleep 120
docker exec -it cmso-service_cmso-robot_1 ls
while [ $? -ne 1 ]; do
  sleep 120
  docker exec -it cmso-service_cmso-robot_1 ls
done

cat up.txt
