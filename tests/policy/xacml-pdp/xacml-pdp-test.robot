*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Policy Xacml PDP Health check
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]    Runs Policy Xacml PDP Statistics
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

ExecuteXacmlPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    CreateMonitorPolicyType
     Wait Until Keyword Succeeds    2 min    5 sec    CreateNewMonitorPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    DeployMonitorPolicy
     Wait Until Keyword Succeeds    2 min    10 sec   GetAbbreviatedDecisionResult
     Wait Until Keyword Succeeds    2 min    10 sec   GetDecision

*** Keywords ***

CreateMonitorPolicyType
     [Documentation]    Create Monitoring Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policies.monitoring.cdap.tca.hi.lo.app.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes  data=${postjson}   headers=${headers}
     Log    Received response from policy2 ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${postjsonobject}   To Json    ${postjson}
     Dictionary Should Contain Key    ${resp.json()}    tosca_definitions_version
     Dictionary Should Contain Key    ${postjsonobject}    tosca_definitions_version

CreateNewMonitorPolicy
     [Documentation]    Create a new Monitoring policy
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes/onap.policies.monitoring.cdap.tca.hi.lo.app/versions/1.0.0/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy4 ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()}    tosca_definitions_version
     Dictionary Should Contain Key    ${postjsonobject}    tosca_definitions_version

DeployMonitorPolicy
     [Documentation]   Runs Policy PAP to deploy a policy
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.monitoring.input.tosca.deploy.json
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/pap/v1/pdps/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy5 ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200

GetStatisticsAfterDeployed
     [Documentation]    Runs Policy Xacml PDP Statistics after policy is deployed
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200
     Should Be Equal As Strings    ${resp.json()['totalPoliciesCount']     1

GetAbbreviatedDecisionResult
    [Documentation]    Get Decision with abbreviated results from Policy Xacml PDP
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${params}=  Create Dictionary      abbrev=true
     ${resp}=   Post Request     policy  /policy/pdpx/v1/decision     params=${params}  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${policy}=    Get From Dictionary    ${resp.json()['policies']}   onap.restart.tca
     Log    Getting from policy ${policy['type']}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Not Contain Key    ${policy}    properties

GetDecision
    [Documentation]    Get Decision from Policy Xacml PDP
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     policy  /policy/pdpx/v1/decision  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     
GetStatisticsAfterDecision
     [Documentation]    Runs Policy Xacml PDP Statistics after Decision request
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200
     Should Be Equal As Strings    ${resp.json()['totalDecisionsCount']     1
     
UndeployMonitorPolicy
     [Documentation]    Runs Policy PAP to undeploy a policy
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/policies/onap.restart.tca     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     
GetStatisticsAfterUndeploy
     [Documentation]    Runs Policy Xacml PDP Statistics after policy is undeployed
     ${auth}=    Create List    healthcheck    zb!XztG34 
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdpx/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200
     Should Be Equal As Strings    ${resp.json()['totalPoliciesCount']     0

     
