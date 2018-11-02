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
#

echo "AAF setup.sh"
# Starting Directory
CURRENT_DIR=$(pwd)

if [ "$(uname)" = "Darwin" ]; then
  SED="sed -i .bak"
else
  SED="sed -i"
fi

# Place the scripts in run order:
source ${SCRIPTS}/common_functions.sh

# Clone AAF Authz repo
CODE_DIR="$WORKSPACE/archives/opt"
mkdir -p $CODE_DIR
cd $CODE_DIR

# Get or refresh AAF Code set
if [ -e authz ]; then
  cd authz
  git pull
else
  git clone --depth 1 http://gerrit.onap.org/r/aaf/authz -b master
  chmod -R 777 authz
  cd authz
fi


# Locate to Docker dir
cd auth/docker
if [ ! -e d.props ]; then
  cp d.props.init d.props
fi
source d.props

# Fill in anything missing
$SED "s/^LATITUDE=.*/LATITUDE=${LATITUDE:=38.0}/" d.props
$SED "s/^LONGITUDE=.*/LONGITUDE=${LONGITUDE:=-72.0}/" d.props
# For Jenkins, gotta use 10001, not 10003
DOCKER_REPOSITORY=nexus3.onap.org:10001
$SED "s/DOCKER_REPOSITORY=.*/DOCKER_REPOSITORY=$DOCKER_REPOSITORY/"  d.props

$SED "s/HOSTNAME=.*/HOSTNAME=aaf.api.simpledemo.onap.org/"  d.props
DOCKER_NAME=$(docker info | grep Name | awk '{print $2}' )
if [ "$DOCKER_NAME" = "minikube" ]; then
  echo "Minikube IP"
  HOST_IP=$(minikube ip)
else 
  echo "Getting IP from Docker $DOCKER_NAME with 'host' method"
  HOST_IP=$(host $DOCKER_NAME | grep -v IPv6 | head -1 | awk '{print $4}')
  if [ -z "$HOST_IP" ]; then
    echo "Trying to get IP from Docker $DOCKER_NAME with 'ip route' method"
    HOST_IP=$(ip route get 8.8.8.8 | awk '{print $3}')
  fi
  if [ -z "$HOST_IP" ]; then
     echo "Critical HOST_IP could not be obtained by 2 different methods.  Exiting..."
     exit
  fi
  echo 
fi
$SED "s/HOST_IP=.*/HOST_IP=$HOST_IP/" d.props

cat d.props

# Pull latest Dockers
AAF_DOCKER_VERSION=${VERSION}
NEXUS_USERNAME=anonymous
NEXUS_PASSWD=anonymous
echo "$NEXUS_PASSWD" | docker login -u $NEXUS_USERNAME --password-stdin $DOCKER_REPOSITORY

docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_cass:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_config:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_cm:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_fs:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_gui:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_hello:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_locate:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_oauth:$AAF_DOCKER_VERSION
docker pull $DOCKER_REPOSITORY/onap/aaf/aaf_service:$AAF_DOCKER_VERSION

# Cassandra Install/Start
cd ../auth-cass/docker
echo Cassandra Install
bash ./dinstall.sh
cd -

# AAF Run
bash ./drun.sh

bash ./aaf.sh cat /opt/app/osaaf/local/org.osaaf.aaf.props

bash ./aaf.sh cat /opt/app/osaaf/local/org.osaaf.aaf.cred.props

docker images

docker ps -a

docker logs aaf_hello

docker logs aaf_locate

docker logs aaf_cm

docker logs aaf_gui

docker logs aaf_fs

docker logs aaf_oauth

docker logs aaf_service

AAF_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aaf_service)
echo AAF_IP=${AAF_IP}

#Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v AAF_IP:${AAF_IP}"
