#!/bin/bash

source ${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh tud

BE_IP=`get-instance-ip.sh sdc-BE`
echo BE_IP=${BE_IP}

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v BE_IP:${BE_IP}"

