#!/bin/bash

function usage {
    echo "usage: setup_sdc_for_sanity.sh {tad|tud}"
    echo "setup sdc and run api test suite: setup_sdc_for_sanity.sh tad"
    echo "setup sdc and run ui test suite: setup_sdc_for_sanity.sh tud"
}

# returns 0: if SDC_LOCAL_IMAGES is set to true value
# returns 1: otherwise
function using_local_images {
    SDC_LOCAL_IMAGES=$(echo "${SDC_LOCAL_IMAGES}" | tr '[:upper:]' '[:lower:]')

    case "$SDC_LOCAL_IMAGES" in
        1|yes|true|Y)
            return 0
            ;;
    esac

    return 1
}

# fail quick if error
set -exo pipefail

echo "This is ${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh"


if [ "$1" != "tad" ] && [ "$1" != "tud" ]; then
    usage
    exit 1
fi

# Clone sdc enviroment template
mkdir -p ${WORKSPACE}/data/environments/
mkdir -p ${WORKSPACE}/data/clone/

cd ${WORKSPACE}/data/clone
if using_local_images && [ -n "$SDC_LOCAL_GITREPO" ] ; then
    if [ -d "$SDC_LOCAL_GITREPO" ] ; then
        rm -rf ./sdc
        cp -a "$SDC_LOCAL_GITREPO" ./sdc
    else
        echo "[ERROR]: Local git repo for sdc does not exist: ${SDC_LOCAL_GITREPO}"
        exit 1
    fi
else
    git clone --depth 1 http://gerrit.onap.org/r/sdc -b ${GERRIT_BRANCH}
fi

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

if using_local_images ; then
    if [ -n "$SDC_LOCAL_TAG" ] ; then
        RELEASE="$SDC_LOCAL_TAG"
    elif [ -z "$SDC_LOCAL_GITREPO" ] ; then
        echo "[WARNING]: Local images used but no tag and no source (git repo) provided for them - we will use tag 'latest'"
        RELEASE=latest
    fi

    echo "[INFO]: We will use the locally built images (tag: ${RELEASE})"
    ${WORKSPACE}/scripts/sdc/docker_run.sh \
        --local \
        -r ${RELEASE} \
        -e ${ENV_NAME} \
        -p 10001 -${TEST_SUITE}
else
    echo "[INFO]: We will download images from the default registry (tag: ${RELEASE})"
    ${WORKSPACE}/scripts/sdc/docker_run.sh \
        -r ${RELEASE} \
        -e ${ENV_NAME} \
        -p 10001 -${TEST_SUITE}
fi

# This file is sourced in another script which is out of our control...
set +e
set +o pipefail

