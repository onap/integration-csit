#!/bin/bash
#
# Copyright 2019 © Samsung Electronics Co., Ltd.
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

echo "This is ${WORKSPACE}/scripts/sdc-dcae-d/setup_sdc_dcaed.sh"

# I am leaving this here for explicity - but the same is already set inside setup sdc...
export ENV_NAME='CSIT'

# run sdc deployment
set -- # to wipe out arguments...
source ${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh
export ROBOT_VARIABLES

# fail quick if error
set -exo pipefail

# prepare dcae-d
mkdir -p "${WORKSPACE}/data/clone/"
cd "${WORKSPACE}/data/clone"
git clone --depth 1 "https://gerrit.onap.org/r/sdc/dcae-d/dt-be-main"

# set enviroment variables
source ${WORKSPACE}/data/clone/dt-be-main/version.properties
export DCAE_RELEASE=$major.$minor-STAGING-latest

cp ${WORKSPACE}/data/clone/dt-be-main/docker/scripts/docker_run.sh ${WORKSPACE}/scripts/sdc-dcae-d/dcaed_docker_run.sh

${WORKSPACE}/scripts/sdc-dcae-d/dcaed_docker_run.sh -r ${DCAE_RELEASE} -e ${ENV_NAME} -p 10001

# This file is sourced in another script which is out of our control...
set +e
set +o pipefail

