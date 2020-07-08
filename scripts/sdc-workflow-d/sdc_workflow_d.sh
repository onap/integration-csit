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
echo "[INFO] This is sdc_workflow_d.sh"
# run sdc deployment
source "${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh"
export ROBOT_VARIABLES

# fail quick if error
set -exo pipefail

export ENV_NAME='CSIT'

function iss_true {
    _value=$(eval echo "\$${1}" | tr '[:upper:]' '[:lower:]')

    case "$_value" in
        1|yes|true|Y)
            return 0
            ;;
    esac

    return 1
}

# returns 0: if SDC_LOCAL_IMAGES is set to true value
# returns 1: otherwise
function using_local_workflow_images {
    iss_true WORKFLOW_LOCAL_IMAGES
}

# cloning workflow directory 
mkdir -p "${WORKSPACE}/data/clone/"
cd "${WORKSPACE}/data/clone"
if using_local_workflow_images && [ -n "$WORKFLOW_LOCAL_GITREPO" ] ; then
    WORKFLOW_LOCAL_GITREPO=$(realpath "$WORKFLOW_LOCAL_GITREPO")
    if [ -d "$WORKFLOW_LOCAL_GITREPO" ] ; then
        rm -rf ./workflow
        cp -a "$WORKFLOW_LOCAL_GITREPO" ./workflow
    else
        echo "[ERROR]: Local git repo for workflow does not exist: ${WORKFLOW_LOCAL_GITREPO}"
        exit 1
    fi
else
    git clone --depth 1 "https://github.com/onap/sdc-sdc-workflow-designer.git" -b ${GERRIT_BRANCH}
fi
# set enviroment variables
source ${WORKSPACE}/data/clone/workflow/version.properties
export WORKFLOW_RELEASE=$major.$minor-STAGING-latest

SDC_CS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdc-cs)
SDC_BE=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sdc-BE)
echo "[INFO] Initialization  of workflow init"
echo ${SDC_CS}
echo ${SDC_BE}
docker run -ti \
    -e "CS_HOST=${SDC_CS}" \
    -e "CS_PORT=9042" \
    -e "CS_AUTHENTICATE=true"\
    -e "CS_USER=asdc_user" \
    -e "CS_PASSWORD=Aa1234%^!" nexus3.onap.org:10001/onap/sdc-workflow-init:latest

echo "[INFO] Initialization  of workflow Backend init"
docker run -d --name "workflow-backend" -e "SDC_PROTOCOL=http" \
    -e "SDC_ENDPOINT=${SDC_BE}:8080" \
    -e "SDC_USER=workflow" \
    -e "SDC_PASSWORD=Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U" \
    -e "CS_HOSTS=${SDC_CS}" \
    -e "CS_PORT=9042" \
    -e "CS_AUTHENTICATE=true"\
    -e "CS_USER=asdc_user" \
    -e "CS_PASSWORD=Aa1234%^!" \
    -e "CS_SSL_ENABLED=false"\
    -e "SERVER_SSL_ENABLED=false" \
    --env JAVA_OPTIONS="${BE_JAVA_OPTIONS}" --publish 8384:8080 --publish 10443:8443 --publish 8000:8000 nexus3.onap.org:10001/onap/sdc-workflow-backend:latest

WORKFLOW_BE=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' workflow-backend)
echo "[INFO] starting workflow designer fronend"
docker run -d --name "workflow-frontend" \
    -e BACKEND="http://${WORKFLOW_BE}:8080"\
    --publish 8484:8080 --publish 11443:8443  nexus3.onap.org:10001/onap/sdc-workflow-frontend:latest

cp "${WORKSPACE}/data/clone/sdc/sdc-os-chef/environments/plugins-configuration.yaml" \
    "${WORKSPACE}/data/environments/plugins-configuration.yaml"

WF_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' workflow-frontend)
WFADDR="http:\/\/${WF_IP}:8080\/workflows"
echo ${WFADDR}
sed -i \
    -e "s/<%= @workflow_discovery_url %>/${WFADDR}/g" \
    -e "s/<%= @workflow_source_url %>/${WFADDR}/g" \
    "${WORKSPACE}/data/environments/plugins-configuration.yaml"

cp "${WORKSPACE}/data/clone/sdc/sdc-os-chef/scripts/docker_run.sh" "${WORKSPACE}/scripts/sdc-workflow-d/"

echo "[INFO] restarting sdc-FE with updated plugin configuration file with Worflow host ip"
docker stop sdc-FE
"${WORKSPACE}/scripts/sdc-workflow-d/docker_run.sh" \
    --local \
    -e "${ENV_NAME}" \
    -p 10001 -d sdc-FE
# This file is sourced in another script which is out of our control...
set +e
set +o pipefail
