*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

Healthcheck
     [Documentation]    Runs Policy Distribution Health check
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_DISTRIBUTION_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_DISTRIBUTION_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /healthcheck     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]    Runs Policy Distribution Statistics
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session https://${POLICY_DISTRIBUTION_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_DISTRIBUTION_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /statistics     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['code']}  200

InvokeDistributionAndRunEventOnEngine
     Wait Until Keyword Succeeds    10 min    10 sec    InvokeDistributionUsingFile And RunEventOnApexEngine

*** Keywords ***

InvokeDistributionUsingFile And RunEventOnApexEngine
    Copy File    ${SCRIPT_DIR}/config/distribution/csar/sample_csar_with_apex_policy.csar    ${SCRIPT_DIR}/config/distribution/csar/temp.csar
    Move File    ${SCRIPT_DIR}/config/distribution/csar/temp.csar    ${SCRIPT_DIR}/config/distribution/temp/sample_csar_with_apex_policy.csar
    Sleep    20 seconds    "Waiting for the Policy Distribution to call Policy API and PAP"
    Create Session   apexSession  http://${APEX_IP}:23324   max_retries=5
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Put Request    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Remove Files    ${SCRIPT_DIR}/config/distribution/temp/sample_csar_with_apex_policy.csar
