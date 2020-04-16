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
     Wait Until Keyword Succeeds    0 min   15 sec  CreateNewMonitorPolicy
     Wait Until Keyword Succeeds    0 min   15 sec  DeployMonitorPolicy
     Wait Until Keyword Succeeds    0 min   15 sec  GetAbbreviatedDecisionResult
     Wait Until Keyword Succeeds    0 min   15 sec  GetMonitoringDecision
     Wait Until Keyword Succeeds    0 min   15 sec  GetNamingDecision

*** Keywords ***

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
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${policy}    type
     Dictionary Should Contain Key    ${policy}    metadata
     Dictionary Should Not Contain Key    ${policy}    type_version
     Dictionary Should Not Contain Key    ${policy}    properties
     Dictionary Should Not Contain Key    ${policy}    name
     Dictionary Should Not Contain Key    ${policy}    version

GetMonitoringDecision
    [Documentation]    Get Decision from Monitoring Policy Xacml PDP
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     policy  /policy/pdpx/v1/decision  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${policy}=    Get From Dictionary    ${resp.json()['policies']}   onap.restart.tca
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${policy}    type
     Dictionary Should Contain Key    ${policy}    metadata
     Dictionary Should Contain Key    ${policy}    type_version
     Dictionary Should Contain Key    ${policy}    properties
     Dictionary Should Contain Key    ${policy}    name
     Dictionary Should Contain Key    ${policy}    version

GetNamingDecision
    [Documentation]    Get Decision from Naming Policy Xacml PDP
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.naming.decision.request.json
     Log    Creating session https://${POLICY_PDPX_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PDPX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     policy  /policy/pdpx/v1/decision  data=${postjson}   headers=${headers}
     Log    Received response from policy ${resp.text}
     ${policy}=    Get From Dictionary    ${resp.json()['policies']}   SDNC_Policy.ONAP_VNF_NAMING_TIMESTAMP
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${policy}    type
     Dictionary Should Contain Key    ${policy}    type_version
     Dictionary Should Contain Key    ${policy}    properties
     Dictionary Should Contain Key    ${policy}    name

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
