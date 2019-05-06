*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

Healthcheck
     [Documentation]    Runs Apex PDP Health check
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${APEX_IP}:6969
     ${session}=    Create Session      policy  https://${APEX_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/apex-pdp/v1/healthcheck     headers=${headers}
     Log    Received response from policy1 ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

ExecuteApexPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    CreateOperationalPolicyType
     Wait Until Keyword Succeeds    2 min    5 sec    CreateNewOperationalPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    DeployOperationalPolicy
     Wait Until Keyword Succeeds    4 min    10 sec    RunEventOnApexEngine

*** Keywords ***

CreateOperationalPolicyType
     [Documentation]    Create Operational Policy Type
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policies.controlloop.operational.Apex.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes  data=${postjson}   headers=${headers}
     Log    Received response from policy2 ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${postjsonobject}   To Json    ${postjson}
     Dictionary Should Contain Key    ${resp.json()}    tosca_definitions_version
     Dictionary Should Contain Key    ${postjsonobject}    tosca_definitions_version

CreateNewOperationalPolicy
     [Documentation]    Create a new Operational Apex policy
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/onap.policies.controlloop.operational.Apex.tosca.json
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/api/v1/policytypes/onap.policies.controlloop.operational.Apex/versions/1.0.0/policies  data=${postjson}   headers=${headers}
     Log    Received response from policy4 ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Key    ${resp.json()}    tosca_definitions_version
     Dictionary Should Contain Key    ${postjsonobject}    tosca_definitions_version

DeployOperationalPolicy
     [Documentation]    Make the PAP to initiate a PDP_UPDATE with policies
     ${auth}=    Create List    healthcheck    zb!XztG34
     ${postjson}=  Get file  ${CURDIR}/data/pdp_update.json
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request   policy  /policy/pap/v1/pdps  data=${postjson}   headers=${headers}
     Log    Received response from policy5 ${resp.text}
     ${postjsonobject}   To Json    ${postjson}
     Should Be Equal As Strings    ${resp.status_code}     200

RunEventOnApexEngine
    Create Session   apexSession  http://${APEX_IP}:23324   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Put Request    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
