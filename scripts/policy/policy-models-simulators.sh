#!/bin/bash
#
# ============LICENSE_START===================================================
#  Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
# ============================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=====================================================
#

source ${SCRIPTS}/policy/config/policy-csit.conf

rm -rf ${WORKSPACE}/simulators
mkdir ${WORKSPACE}/simulators
cd ${WORKSPACE}/simulators

POLICY_MODELS_VERSION_EXTRACT="$(curl -q --silent https://git.onap.org/policy/models/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_MODELS_VERSION="${POLICY_MODELS_VERSION_EXTRACT}"
echo ${POLICY_MODELS_VERSION}

# download simulators tarball and build docker image
git clone --depth 1 https://gerrit.onap.org/r/policy/models -b ${GERRIT_BRANCH}
cd models/models-sim/policy-models-simulators
item=`curl --silent -L ${NEXUS_URL}/org/onap/policy/models/sim/policy-models-simulators/${POLICY_MODELS_VERSION} | egrep 'policy-models-simulators-.*tarball' | cut '-d"' -f2 | egrep 'gz$' | sort | tail -1`
mkdir target
#curl -L $item -o target/policy-models-simulators-${POLICY_MODELS_VERSION}-tarball.tar.gz
#bash ./src/main/package/docker/docker_build.sh

cd ${WORKSPACE}
