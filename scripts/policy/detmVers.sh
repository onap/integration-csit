SCRIPTS=${SCRIPTS-scripts}

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
