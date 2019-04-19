*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Policy PAP Health check
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]    Runs Policy PAP Statistics
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

CreatePdpGroups
     [Documentation]    Runs Policy PAP Create PDP Groups
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/create.group.request.json
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Post Request     policy  /policy/pap/v1/pdps    data=${postjson}     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

ActivatePdpGroup
     [Documentation]    Runs Policy PAP Change PDP Group State to ACTIVE
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Put Request     policy  /policy/pap/v1/pdps/groups/create.group.request?state=ACTIVE     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

QueryPdpGroups
     [Documentation]    Runs Policy PAP Query PDP Groups
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/pdps     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['groups'][0]['name']}  controlloop
     Should Be Equal As Strings    ${resp.json()['groups'][1]['name']}  create.group.request
     Should Be Equal As Strings    ${resp.json()['groups'][1]['pdpGroupState']}  ACTIVE
     Should Be Equal As Strings    ${resp.json()['groups'][2]['name']}  monitoring

UndeployPolicy
     [Documentation]    Runs Policy PAP Undeploy a Policy from PDP Groups
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/policies/onap.restart.tca     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

QueryPdpGroupsAfterUndeploy
     [Documentation]    Runs Policy PAP Query PDP Groups after Undeploy
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/pdps     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['groups'][1]['name']}  create.group.request
     Should Be Equal As Strings    ${resp.json()['groups'][1]['pdpSubgroups'][0]['policies']}  []

DeactivatePdpGroup
     [Documentation]    Runs Policy PAP Change PDP Group State to PASSIVE
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Put Request     policy  /policy/pap/v1/pdps/groups/create.group.request?state=PASSIVE     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

DeletePdpGroups
     [Documentation]    Runs Policy PAP Delete PDP Groups
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Delete Request     policy  /policy/pap/v1/pdps/groups/create.group.request     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

QueryPdpGroupsAfterDelete
     [Documentation]    Runs Policy PAP Query PDP Groups after Delete
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_PAP_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_PAP_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pap/v1/pdps     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['groups'][0]['name']}  controlloop
     Should Be Equal As Strings    ${resp.json()['groups'][1]['name']}  monitoring
