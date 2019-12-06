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
echo "Current Dir: ${PWD}"

# Locate to Docker dir
cd auth/docker
cp d.props.csit d.props

echo "Current Dir: ${PWD}"
source d.props

# Fill in anything missing
$SED "s/^LATITUDE=.*/LATITUDE=${LATITUDE:=38.0}/" d.props
$SED "s/^LONGITUDE=.*/LONGITUDE=${LONGITUDE:=-72.0}/" d.props
$SED "s/^LONGITUDE=.*/LONGITUDE=${LONGITUDE:=-72.0}/" d.props
# For Jenkins, gotta use 10001, not 10003
DOCKER_REPOSITORY=nexus3.onap.org:10001
$SED "s/DOCKER_REPOSITORY=.*/DOCKER_REPOSITORY=$DOCKER_REPOSITORY/"  d.props

$SED "s/HOSTNAME=.*/HOSTNAME=aaf.api.simpledemo.onap.org/"  d.props
DOCKER_NAME=$(docker info | grep Name | awk '{print $2}' )
echo "Docker Name is $DOCKER_NAME"


#if [ "$DOCKER_NAME" = "minikube" ]; then
#  echo "Minikube IP"
#  HOST_IP=$(minikube ip)
#else 
#  echo "Trying to get IP from Docker $DOCKER_NAME with 'ip route' method"
#  # ip route get 8.8.8.8
#  HOST_IP=$(ip route get 8.8.8.8 | awk '{print $7}')
#  if [ -z "$HOST_IP" ]; then
#     echo "Critical HOST_IP could not be obtained by 2 different methods.  Exiting..."
#     exit
#  fi
#  echo 
#fi
#$SED "s/HOST_IP=.*/HOST_IP=$HOST_IP/" d.props

if [ -z "$SKIP_PULL" ]; then
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
  docker pull $DOCKER_REPOSITORY/onap/aaf/aafservice:$AAF_DOCKER_VERSION
fi
# Cassandra Install/Start
cd ../auth-cass/docker
echo Cassandra Install
bash ./dinstall.sh
cd -

source d.props
cat d.props

# AAF Run
bash ./drun.sh

docker images

docker ps -a

for C in aaf-service aaf-locate aaf-oauth aaf-cm aaf-gui aaf-hello aaf-fs; do
  docker logs $C
done

bash ./aaf.sh wait aaf-service

AAF_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aaf-service)
echo AAF_IP=${AAF_IP}

openssl s_client -connect $AAF_IP:8100

export ROBOT_VARIABLES="-v AAF_IP:${AAF_IP}"
