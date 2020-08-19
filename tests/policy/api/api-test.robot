*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Policy Api Health check
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/api/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]    Runs Policy Api Statistics
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/api/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

RetrievePolicyTypes
     [Documentation]    Gets Policy Types
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/api/v1/policytypes     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['version']}  1.0.0

CreateTCAPolicyTypeV1
     [Documentation]    Create TCA Policy Type Version 1. Trying to create an existing policy type with any change and same version should cause error.
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.tcagen2.v1.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}    406

CreateTCAPolicyTypeV2
     [Documentation]    Create TCA Policy Type Version 2
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.tcagen2.v2.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${postjsonobject}   To Json    ${postjson}
     Dictionary Should Contain Key    ${resp.json()}    tosca_definitions_version
     Dictionary Should Contain Key    ${postjsonobject}    tosca_definitions_version

RetrieveMonitoringPolicyTypes
     [Documentation]    Retrieve Monitoring related Policy Types
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  /policy/api/v1/policytypes/onap.policies.Monitoring     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     List Should Contain Value    ${resp.json()['policy_types']}  onap.policies.Monitoring


CreateNewMonitoringPolicyV1
     [Documentation]    Create a new Monitoring TCA policy version 1
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v1.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key	${postjsonobject['topology_template']['policies'][0]}  onap.restart.tca

SimpleCreateNewMonitoringPolicyV1
     [Documentation]    Create a new Monitoring TCA policiy version 1 using simple endpoint. Trying to create an existing policy with any change and same version should cause error.
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v1_2.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}    406

SimpleCreateNewMonitoringPolicyV2
     [Documentation]    Create a new Monitoring TCA policiy version 2 using simple endpoint
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v2.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key	${postjsonobject['topology_template']['policies'][0]}  onap.restart.tca

RetrievePoliciesOfType
     [Documentation]    Retrieve all Policies Created for a specific Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${expjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v1.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies     headers=${headers}
     Log    Received response from policy ${resp.text}
     ${expjsonobject}   To Json    ${expjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key	${expjsonobject['topology_template']['policies'][0]}  onap.restart.tca

RetrieveAllPolicies
     [Documentation]    Retrieve all Policies
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${expjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v1.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  /policy/api/v1/policies     headers=${headers}
     Log    Received response from policy ${resp.text}
     ${expjsonobject}   To Json    ${expjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Contain      ${expjsonobject['topology_template']['policies'][0]}  onap.restart.tca

RetrieveSpecificPolicy
     [Documentation]    Retrieve a specific Policy named 'onap.restart.tca' and version '1.0.0'
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${expjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.v1.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0/     headers=${headers}
     Log    Received response from policy ${resp.text}
     ${expjsonobject}   To Json    ${expjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key      ${expjsonobject['topology_template']['policies'][0]}  onap.restart.tca

DeleteSpecificPolicy
     [Documentation]    Delete a specific Policy named 'onap.restart.tca' and version '1.0.0'
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request   policy  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${resp}=   Delete Request   policy  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0     headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     404

DeleteSpecificPolicyV2
     [Documentation]    Delete the Monitoring Policy Version 2 of the TCA Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0     headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     404

DeleteSpecificPolicyTypeV1
     [Documentation]    Delete the TCA Policy Type Version 1
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0    headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     404

DeleteSpecificPolicyTypeV2
     [Documentation]    Delete the TCA Policy Type Version 2
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0    headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     404
