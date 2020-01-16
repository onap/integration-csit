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

CreateTCAPolicyType
     [Documentation]    Create TCA Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34 
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.cdap.tca.hi.lo.app.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}    406

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


CreateNewMonitoringPolicy
     [Documentation]    Create a new Monitoring TCA policy
     ${auth}=    Create List    healthcheck    zb!XztG34 
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key	${postjsonobject['topology_template']['policies'][0]}  onap.restart.tca

SimpleCreateNewMonitoringPolicy
     [Documentation]    Create a new Monitoring TCA policiy using simple endpoint
     ${auth}=    Create List    healthcheck    zb!XztG34 
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     406

RetrievePoliciesOfType
     [Documentation]    Retrieve all Policies Created for a specific Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${expjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies     headers=${headers}
     Log    Received response from policy ${resp.text}
     ${expjsonobject}   To Json    ${expjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()['topology_template']['policies'][0]}  onap.restart.tca
     Dictionary Should Contain Key	${expjsonobject['topology_template']['policies'][0]}  onap.restart.tca

DeleteSpecificPolicy
     [Documentation]    Delete Policy of a Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies/onap.restart.tca/versions/1.0.0     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${resp}=   Delete Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies/onap.restart.tca/versions/1.0.0     headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     404
