#!/bin/bash -x
#
# Copyright 2017-2020 AT&T Intellectual Property. All rights reserved.
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
echo "This is ${WORKSPACE}/scripts/policy/engine.sh"


# the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ${DIR}

# the temp directory used, within $DIR
# omit the -p parameter to create a temporal directory in the default location
WORK_DIR=`mktemp -d -p "$DIR"`
echo ${WORK_DIR}

cd ${WORK_DIR}

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# bring down maven
mkdir maven
cd maven
# download maven from automatically selected mirror server
curl -vLO  "https://www.apache.org/dyn/mirrors/mirrors.cgi?cca2=us&preferred=http://apache.claz.org/&action=download&filename=maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
if ! tar -xzvf apache-maven-3.3.9-bin.tar.gz ; then
    echo "Installation of maven has failed!"
    exit 1
fi
ls -l
export PATH=${PATH}:${WORK_DIR}/maven/apache-maven-3.3.9/bin
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn -v
cd ..

ifconfig

export IP=`ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $NF}'`
if [ -z "$IP" ]; then
	echo "Could not determine IP address"
	exit 1
fi
echo $IP

if ! ifconfig docker0; then
	export DOCKER_IP="$IP"
else
	export DOCKER_IP=`ifconfig docker0 | awk -F: '/inet addr/ {gsub(/ .*/,"",$2); print $2}'`
fi
echo $DOCKER_IP

git clone http://gerrit.onap.org/r/oparent

git clone http://gerrit.onap.org/r/policy/engine
cd engine/packages/docker 
${WORK_DIR}/maven/apache-maven-3.3.9/bin/mvn prepare-package --settings ${WORK_DIR}/oparent/settings.xml
docker build -t onap/policy-pe target/policy-pe

cd ${WORK_DIR}
git clone http://gerrit.onap.org/r/policy/docker
cd docker

echo $IP > config/pe/ip_addr.txt
ls -l config/pe/ip_addr.txt
cat config/pe/ip_addr.txt

export MTU=9126

export PRELOAD_POLICIES=false

#sed -i '/depends_on/ s/^/      user: "1001:1001"\n/' docker-compose-integration.yml
sudo docker-compose -f docker-compose-integration.yml up -d 

if [ ! $? -eq 0 ]; then
	echo "Docker compose failed"
	exit 1
fi 

docker ps

PDP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pdp`
echo ${PDP_IP}

PAP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pap`
echo ${PAP_IP}

BRMS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' brmsgw`
echo ${BRMS_IP}

NEXUS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' nexus`
echo ${NEXUS_IP}

MARIADB_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' mariadb`
echo ${MARIADB_IP}

sleep 3m

docker logs mariadb 2>&1 | grep -q "mysqld: ready for connections"
if [ $? -eq 0 ]; then
	# mariadb is ok - sleep a little longer for others
	sleep 2m

else
	echo mariadb is not ready
	echo Restarting...

	docker kill pdp pap brmsgw nexus mariadb
	docker rm -f pdp pap brmsgw nexus mariadb

	docker-compose -f docker-compose-integration.yml up -d 
	
	if [ ! $? -eq 0 ]; then
		echo "Docker compose failed"
		exit 1
	fi 
	
	docker ps
	
	PDP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pdp`
	echo ${PDP_IP}
	
	PAP_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' pap`
	echo ${PAP_IP}
	
	BRMS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' brmsgw`
	echo ${BRMS_IP}
	
	NEXUS_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' nexus`
	echo ${NEXUS_IP}
	
	MARIADB_IP=`docker inspect --format '{{ .NetworkSettings.Networks.docker_default.IPAddress}}' mariadb`
	echo ${MARIADB_IP}
	
	sleep 5m
fi

netstat -tnl

${DIR}/wait_for_port.sh ${MARIADB_IP} 3306
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${MARIADB_IP} 3306"
        telnet ${MARIADB_IP} 3306 < /dev/null
        nc -vz ${MARIADB_IP} 3306
        docker logs mariadb
        exit $rc
fi

${DIR}/wait_for_port.sh ${NEXUS_IP} 8081
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${NEXUS_IP} 8081"
	netstat -tnl
        telnet ${NEXUS_IP} 8081 < /dev/null
        nc -vz ${NEXUS_IP} 8081
        docker logs nexus
        exit $rc
fi

${DIR}/wait_for_port.sh ${PAP_IP} 9091
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${PAP_IP} 9091"
	netstat -tnl
        telnet ${PAP_IP} 9091 < /dev/null
        nc -vz ${PAP_IP} 9091
        docker logs pap
        exit $rc
fi

${DIR}/wait_for_port.sh ${PDP_IP} 8081
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${PDP_IP} 8081"
	netstat -tnl
        telnet ${PDP_IP} 8081 < /dev/null
        nc -vz ${PDP_IP} 8081
        docker logs pdp
        exit $rc
fi

${DIR}/wait_for_port.sh ${BRMS_IP} 9989
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${BRMS_IP} 9989"
	netstat -tnl
        telnet ${BRMS_IP} 9989" < /dev/null
        nc -vz ${BRMS_IP} 9989"
        docker logs brmsgw
        exit $rc
fi

docker logs pap
docker logs pdp
docker logs brmsgw

TIME_OUT=300
INTERVAL=20 
TIME=0 
while [ "$TIME" -lt "$TIME_OUT" ]; do 
	
	curl -k -i -v -H 'Content-Type: application/json' -H 'Accept: application/json' -H 'ClientAuth: cHl0aG9uOnRlc3Q=' -H 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' -H 'Environment: TEST' -d '{"policyName": ".*"}' https://${PDP_IP}:8081/pdp/api/getConfig && break
	
echo Sleep: $INTERVAL seconds before testing if Policy is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds 
  sleep $INTERVAL 
  TIME=$(($TIME+$INTERVAL))
	
done

#
# Add more sleep for everything to settle
#
sleep 3m
