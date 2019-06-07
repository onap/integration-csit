#!/bin/bash

function usage {
    echo "usage: setup_sdc_for_sanity.sh {tad|tud}"
    echo "setup sdc and run api test suite: setup_sdc_for_sanity.sh tad"
    echo "setup sdc and run ui test suite: setup_sdc_for_sanity.sh tud"
}

set -x

echo "This is ${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh"


if [ "$1" != "tad" ] && [ "$1" != "tud" ]; then
    usage
    exit 1
fi

# Clone sdc enviroment template
mkdir -p ${WORKSPACE}/data/environments/
mkdir -p ${WORKSPACE}/data/clone/

cd ${WORKSPACE}/data/clone
git clone --depth 1 http://gerrit.onap.org/r/sdc -b ${GERRIT_BRANCH}

chmod -R 777 ${WORKSPACE}/data/clone

# set enviroment variables

export ENV_NAME='CSIT'
export MR_IP_ADDR='10.0.0.1'
export TEST_SUITE=$1

ifconfig
IP_ADDRESS=`ip route get 8.8.8.8 | awk '/src/{ print $7 }'`
export HOST_IP=$IP_ADDRESS

# setup enviroment json

cat ${WORKSPACE}/data/clone/sdc/sdc-os-chef/environments/Template.json | sed "s/yyy/"$IP_ADDRESS"/g" > ${WORKSPACE}/data/environments/$ENV_NAME.json
sed -i "s/xxx/"$ENV_NAME"/g" ${WORKSPACE}/data/environments/$ENV_NAME.json
sed -i "s/\"ueb_url_list\":.*/\"ueb_url_list\": \""$MR_IP_ADDR","$MR_IP_ADDR"\",/g" ${WORKSPACE}/data/environments/$ENV_NAME.json
sed -i "s/\"fqdn\":.*/\"fqdn\": [\""$MR_IP_ADDR"\", \""$MR_IP_ADDR"\"]/g" ${WORKSPACE}/data/environments/$ENV_NAME.json

cp ${WORKSPACE}/data/clone/sdc/sdc-os-chef/scripts/docker_run.sh ${WORKSPACE}/scripts/sdc/

source ${WORKSPACE}/data/clone/sdc/version.properties
export RELEASE=$major.$minor-STAGING-latest

${WORKSPACE}/scripts/sdc/docker_run.sh -r ${RELEASE} -e ${ENV_NAME} -p 10001 -${TEST_SUITE}

sleep 120

#monitor test processes

TIME_OUT=1200
INTERVAL=20
TIME=0
CID=`docker ps | grep tests |  awk '{print $1}'`

while [ "$TIME" -lt "$TIME_OUT" ]; do
  
PID=`docker exec -i $CID ps -ef | grep java | awk '{print $1}'`

echo sanity PID is -- $PID
  
if [ -z "$PID" ]
 then
    echo SDC sanity finished in $TIME seconds
    break
  fi

  echo Sleep: $INTERVAL seconds before testing if SDC sanity completed. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]
 then
   echo TIME OUT: SDC sanity was NOT completed in $TIME_OUT seconds... Could cause problems for tests...
fi




