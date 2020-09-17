# ============LICENSE_START=======================================================
#  Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
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

SCRIPTS="${SCRIPTS-scripts}"

source ${SCRIPTS}/policy/config/policy-csit.conf
export POLICY_MARIADB_VER

echo POLICY_MARIADB_VER=${POLICY_MARIADB_VER}

POLICY_API_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/api/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_API_VERSION=${POLICY_API_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_API_VERSION=${POLICY_API_VERSION}

POLICY_PAP_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/pap/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_PAP_VERSION=${POLICY_PAP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_PAP_VERSION=${POLICY_PAP_VERSION}

POLICY_XACML_PDP_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/xacml-pdp/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_XACML_PDP_VERSION=${POLICY_XACML_PDP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_XACML_PDP_VERSION=${POLICY_XACML_PDP_VERSION}

POLICY_DROOLS_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/drools-pdp/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DROOLS_VERSION=${POLICY_DROOLS_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DROOLS_VERSION=${POLICY_DROOLS_VERSION}

POLICY_DROOLS_APPS_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/drools-applications/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DROOLS_APPS_VERSION=${POLICY_DROOLS_APPS_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DROOLS_APPS_VERSION=${POLICY_DROOLS_APPS_VERSION}

POLICY_APEX_PDP_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/apex-pdp/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_APEX_PDP_VERSION=${POLICY_APEX_PDP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_APEX_PDP_VERSION=${POLICY_APEX_PDP_VERSION}

POLICY_DISTRIBUTION_VERSION=$(
    curl -q --silent \
      https://git.onap.org/policy/distribution/plain/pom.xml?h=${GERRIT_BRANCH} |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DISTRIBUTION_VERSION=${POLICY_DISTRIBUTION_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DISTRIBUTION_VERSION=${POLICY_DISTRIBUTION_VERSION}
