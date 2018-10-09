#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP AAF
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#
# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone AAF Authz repo
mkdir -p $WORKSPACE/archives/opt
cd $WORKSPACE/archives/opt


HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}

CURRENT_DIR=$(pwd) export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1)

NEXUS_USERNAME=anonymous
NEXUS_PASSWD=anonymous
NEXUS_DOCKER_REPO=nexus3.onap.org:10001
AAF_DOCKER_VERSION=2.1.2-SNAPSHOT

docker login -u $NEXUS_USERNAME -p "$NEXUS_PASSWD" $NEXUS_DOCKER_REPO

docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_cass:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_config:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_cm:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_fs:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_gui:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_hello:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_locate:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_oauth:$AAF_DOCKER_VERSION
docker pull $NEXUS_DOCKER_REPO/onap/aaf/aaf_service:$AAF_DOCKER_VERSION

git clone --depth 1 http://gerrit.onap.org/r/aaf/authz -b master
git pull
chmod -R 777 authz
cd authz
CURRENT_DIR=$(pwd)

pwd

if [ ! -e auth/csit/d.props ]; then
  cp auth/csit/d.props.init auth/csit/d.props
fi




NEXUS_USERNAME=anonymous
NEXUS_PASSWD=anonymous
NEXUS_DOCKER_REPO=nexus3.onap.org:10001
sed -i "s/DOCKER_REPOSITORY=.*/DOCKER_REPOSITORY=$NEXUS_DOCKER_REPO/" auth/csit/d.props
. auth/csit/d.props


HOSTNAME=`hostname`
FQDN=aaf.api.simpledemo.onap.org
HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}')
export HOST_IP=${HOST_IP}


CASS_IP=`docker inspect aaf_cass | grep '"IPAddress' | head -1 | cut -d '"' -f 4`
CASS_HOST="cass.aaf.osaaf.org:"$CASS_IP

cd auth/auth-cass/docker
if [ "`docker container ls | grep aaf_cass`" = "" ]; then
  # Cassandra Install
  echo Cassandra Install
  bash ./dinstall.sh
fi

CASS_IP=`docker inspect aaf_cass | grep '"IPAddress' | head -1 | cut -d '"' -f 4`
CASS_HOST="cass.aaf.osaaf.org:"$CASS_IP
if [ ! -e $WORKSPACE/archives/opt/authz/auth/csit/cass.props ]; then
  cp $WORKSPACE/archives/opt/authz/auth/csit/cass.props.init $WORKSPACE/archives/opt/authz/auth/csit/cass.props
fi

sed -i "s/CASS_HOST=.*/CASS_HOST="$CASS_HOST"/g" $WORKSPACE/archives/opt/authz/auth/csit/cass.props
# TODO Pull from Config Dir
if [ "$LATITUDE" = "" ]; then
  LATITUDE=37.781
  LONGITUDE=-122.261
  sed -i "s/LATITUDE=.*/LATITUDE=$LATITUDE/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props
  sed -i "s/LONGITUDE=.*/LONGITUDE=$LONGITUDE/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props
fi

sed -i "s/VERSION=.*/VERSION=$VERSION/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props
sed -i "s/HOSTNAME=.*/HOSTNAME=$HOSTNAME/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props
sed -i "s/HOST_IP=.*/HOST_IP=$HOST_IP/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props
sed -i "s/AAF_REGISTER_AS=.*/AAF_REGISTER_AS=$FQDN/g" $WORKSPACE/archives/opt/authz/auth/csit/d.props

pwd

cd ../../

pwd

cd csit
tty
# Need new Deployment system properties
bash ./aaf.sh

# run it
bash ./drun.sh

docker ps -a

# Wait for initialization of Docker containers
for i in {1..50}; do
        if [ $(docker inspect --format '{{ .State.Running }}' aaf_service) ] && \
                [ $(docker inspect --format '{{ .State.Running }}' aaf_locate) ] && \
                [ $(docker inspect --format '{{ .State.Running }}' aaf_gui) ]
        then
                echo "aaf Service Running"
                break
        else
                echo sleep $i
                sleep $i
        fi
done



AAF_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aaf_service)
CASSANDRA_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aaf_cass)

echo AAF_IP=${AAF_IP}
echo CASSANDRA_IP=${CASSANDRA_IP}

# Wait for initialization of docker services
for i in {1..12}; do
   curl -k -u aaf_admin@people.osaaf.org:demo123456! https://${AAF_IP}:8100/authz/nss/org.osaaf.people && break
    echo sleep $i
    sleep $i
done

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v AAF_IP:${AAF_IP}"