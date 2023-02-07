#!/bin/bash -x
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
# This script installs common libraries required by CSIT tests
#

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

TESTPLANDIR=${WORKSPACE}/${TESTPLAN}

# Assume that if ROBOT_VENV is set and virtualenv with system site packages can be activated,
# ci-management/jjb/integration/include-raw-integration-install-robotframework.sh has already
# been executed

if [ -f ${WORKSPACE}/env.properties ]; then
    source ${WORKSPACE}/env.properties
fi
ls -l -R ${ROBOT3_VENV}
if [ -f ${ROBOT3_VENV}/bin/activate ]; then
    source ${ROBOT3_VENV}/bin/activate
else
    rm -rf /tmp/ci-management
    rm -f ${WORKSPACE}/env.properties
    cd /tmp
    git clone "https://gerrit.onap.org/r/ci-management"
    source /tmp/ci-management/jjb/integration/include-raw-integration-install-robotframework.sh
fi

# install required Robot libraries
pip install robotframework-extendedselenium2library==0.9.1

# install eteutils
mkdir -p ${ROBOT3_VENV}/src/onap
rm -rf ${ROBOT3_VENV}/src/onap/testsuite
pip install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==11.0.0.*' --pre

pip freeze

# install chrome driver
if [ ! -x ${ROBOT3_VENV}/bin/chromedriver ]; then
    pushd ${ROBOT3_VENV}/bin
    wget -N http://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
    unzip chromedriver_linux64.zip
    chmod +x chromedriver
    popd
fi
