#!/bin/bash

set -x

echo "This is ${WORKSPACE}/scripts/sdc/setup_sdc_dcaed.sh"

# Clone sdc enviroment template
mkdir -p ${WORKSPACE}/data/environments/
mkdir -p ${WORKSPACE}/data/clone/
cd ${WORKSPACE}/data/clone
git clone --depth 1 http://gerrit.onap.org/r/sdc/dcae-d/dt-be-main
git clone --depth 1 http://gerrit.onap.org/r/sdc

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
  
source ${WORKSPACE}/data/clone/sdc/version.properties
export RELEASE=$major.$minor-STAGING-latest
source ${WORKSPACE}/data/clone/dt-be-main/version.properties
export DCAE_RELEASE=$major.$minor-STAGING-latest
export DEP_ENV=$ENV_NAME

cp ${WORKSPACE}/data/clone/sdc/sdc-os-chef/scripts/docker_run.sh ${WORKSPACE}/scripts/sdc/
cp ${WORKSPACE}/data/clone/dt-be-main/docker/scripts/docker_run.sh ${WORKSPACE}/scripts/sdc/dcaed_docker_run.sh

${WORKSPACE}/scripts/sdc/docker_run.sh -r ${RELEASE} -e ${ENV_NAME} -p 10001
${WORKSPACE}/scripts/sdc/dcaed_docker_run.sh -r ${DCAE_RELEASE} -e ${ENV_NAME} -p 10001


