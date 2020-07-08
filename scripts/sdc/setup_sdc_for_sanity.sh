#!/bin/bash

function usage {
cat <<EOF
USAGE
    setup_sdc_for_sanity.sh [tad|tud]

EXAMPLES
    setup_sdc_for_sanity.sh
        just setup sdc component (containers)

    setup_sdc_for_sanity.sh tad
        setup sdc and run api test suite

    setup_sdc_for_sanity.sh tud
        setup sdc and run ui test suite
EOF
}

# arg: <variable name>
# returns 0: if <variable name> is set to true value
# returns 1: otherwise
function is_true {
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
function using_local_images {
    is_true SDC_LOCAL_IMAGES
}

# returns 0: if SDC_TEST_HTTPS is set to true value
# returns 1: otherwise
function using_https {
    is_true SDC_TEST_HTTPS
}

# fail quick if error
set -exo pipefail

echo "This is ${WORKSPACE}/scripts/sdc/setup_sdc_for_sanity.sh"
echo "lets check what is ${1} ${2}"
ENABLE_SIMULATOR=
case "$1" in
    tad|tud)
        # enable test
        export TEST_SUITE="-${1}"
        ;;
    '')
        # we will just setup sdc - no tests
        export TEST_SUITE=""
        ENABLE_SIMULATOR="--simulator"
        # this is mandatory
        ;;
    *)
        export TEST_SUITE=""
        ENABLE_SIMULATOR="--simulator"
    #     # usage
    #     exit 1
        ;;
esac
echo "Lets check is simulator is enabled or not ${ENABLE_SIMULATOR}"
# Clone sdc enviroment template
mkdir -p "${WORKSPACE}/data/environments/"
mkdir -p "${WORKSPACE}/data/clone/"

cd "${WORKSPACE}/data/clone"
if using_local_images && [ -n "$SDC_LOCAL_GITREPO" ] ; then
    SDC_LOCAL_GITREPO=$(realpath "$SDC_LOCAL_GITREPO")
    if [ -d "$SDC_LOCAL_GITREPO" ] ; then
        rm -rf ./sdc
        cp -a "$SDC_LOCAL_GITREPO" ./sdc
        # echo "[skipping copying git repo of sdc]"
    else
        echo "[ERROR]: Local git repo for sdc does not exist: ${SDC_LOCAL_GITREPO}"
        exit 1
    fi
else
    git clone --depth 1 "https://gerrit.onap.org/r/sdc" -b ${GERRIT_BRANCH}
fi

# TODO: why?
chmod -R 777 "${WORKSPACE}/data/clone"

# set enviroment variables

export ENV_NAME='CSIT'
export MR_IP_ADDR='10.0.0.1'

ip a
IP_ADDRESS=`ip route get 8.8.8.8 | awk '/src/{ print $7 }'`
export HOST_IP="$IP_ADDRESS"

# setup enviroment json
# TODO: use jq or find a better way altogether...
cp "${WORKSPACE}/data/clone/sdc/sdc-os-chef/environments/Template.json" \
    "${WORKSPACE}/data/environments/$ENV_NAME.json"
sed -i \
    -e "s/xxx/${ENV_NAME}/g" \
    -e "s/yyy/${IP_ADDRESS}/g" \
    -e "s/\"ueb_url_list\":.*/\"ueb_url_list\": \"${MR_IP_ADDR},${MR_IP_ADDR}\",/g" \
    -e "s/\"fqdn\":.*/\"fqdn\": [\"${MR_IP_ADDR}\", \"${MR_IP_ADDR}\"]/g" \
    "${WORKSPACE}/data/environments/$ENV_NAME.json"
if using_https ; then
    # this is very fragile (as all above) and relies on the current state of Template.json in another project...
    # using jq filters would be much better approach and no need for some "yyy"...
    sed -i \
        -e 's/"disableHttp":[[:space:]]*"\?[[:alnum:]]*"\?/"disableHttp": true/' \
        "${WORKSPACE}/data/environments/$ENV_NAME.json"
fi

cp "${WORKSPACE}/data/clone/sdc/sdc-os-chef/scripts/docker_run.sh" "${WORKSPACE}/scripts/sdc/"

source "${WORKSPACE}/data/clone/sdc/version.properties"
export RELEASE="${major}.${minor}-STAGING-latest"

if using_local_images ; then
    if [ -n "$SDC_LOCAL_TAG" ] ; then
        RELEASE="$SDC_LOCAL_TAG"
    elif [ -z "$SDC_LOCAL_GITREPO" ] ; then
        echo "[WARNING]: Local images used but no tag and no source (git repo) provided for them - we will use tag 'latest'"
        RELEASE=latest
    fi

    echo "[INFO]: We will use the locally built images (tag: ${RELEASE})"
    "${WORKSPACE}/scripts/sdc/docker_run.sh" \
        --local \
        -r "${RELEASE}" \
        -e "${ENV_NAME}" \
        -p 10001 ${TEST_SUITE} ${ENABLE_SIMULATOR}
else
    echo "[INFO]: We will download images from the default registry (tag: ${RELEASE})"
    ${WORKSPACE}/scripts/sdc/docker_run.sh \
        -r "${RELEASE}" \
        -e "${ENV_NAME}" \
        -p 10001 ${TEST_SUITE} ${ENABLE_SIMULATOR}
fi

# final step if the robot test needs to be adjusted
# TODO: again grab the values from Template directly with jq
# jq should be mandatory installed package (is it?)
if using_https ; then
    ROBOT_VARIABLES="${ROBOT_VARIABLES} \
        -v SDC_FE_PROTOCOL:https \
        -v SDC_FE_PORT:9443 \
        -v SDC_BE_PROTOCOL:https \
        -v SDC_BE_PORT:8443 \
        -v SDC_ONBOARDING_BE_PROTOCOL:https \
        -v SDC_ONBOARDING_BE_PORT:8443 \
        "
else
    ROBOT_VARIABLES="${ROBOT_VARIABLES} \
        -v SDC_FE_PROTOCOL:http \
        -v SDC_FE_PORT:8181 \
        -v SDC_BE_PROTOCOL:http \
        -v SDC_BE_PORT:8080 \
        -v SDC_ONBOARDING_BE_PROTOCOL:http \
        -v SDC_ONBOARDING_BE_PORT:8081 \
        "
fi

# This file is sourced in another script which is out of our control...
set +e
set +o pipefail

