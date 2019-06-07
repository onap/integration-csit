#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
# ================================================================================
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
# Select branch
source ${SCRIPTS}/policy/config/policy-csit.conf
echo ${GERRIT_BRANCH}

sudo apt-get -y install libxml2-utils
export POLICY_DISTRIBUTION_VERSION="$(curl -q --silent https://git.onap.org/policy/distribution/plain/pom.xml?h=${GERRIT_BRANCH} | xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)"
export POLICY_DISTRIBUTION_VERSION=$POLICY_DISTRIBUTION_VERSION"-latest"
echo ${POLICY_DISTRIBUTION_VERSION}
docker run -d --name policy-distribution -p 6969:6969 -it nexus3.onap.org:10001/onap/policy-distribution:${POLICY_DISTRIBUTION_VERSION} --rm policy-distribution

POLICY_DISTRIBUTION_IP=`get-instance-ip.sh policy-distribution`
echo DISTRIBUTION IP IS ${POLICY_DISTRIBUTION_IP}

${SCRIPTS}/policy/wait_for_port.sh ${POLICY_DISTRIBUTION_IP} 6969
rc=$?
if [[ $rc != 0 ]]; then
        echo "cannot open ${POLICY_DISTRIBUTION_IP} 6969"
        docker logs policy-distribution
        exit $rc
fi

ROBOT_VARIABLES="-v POLICY_DISTRIBUTION_IP:${POLICY_DISTRIBUTION_IP}"
