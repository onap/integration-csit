*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  https://localhost:8443   auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp

*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

List TCAs
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/getAllNames
    Should Contain Match    ${resp}   *LOOP_iYTIP_v1_0_ResourceInstanceName1_tca*
    Should Contain Match    ${resp}   *tca_2*
    Should Contain Match    ${resp}   *LOOP_iYTIP_v1_0_ResourceInstanceName1_tca_3*

Open TCA1
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/LOOP_iYTIP_v1_0_ResourceInstanceName1_tca
    Should Contain Match    ${resp}   *LOOP_iYTIP_v1_0_ResourceInstanceName1_tca*
    Should Contain Match    ${resp}   *GENERATED_POLICY_ID_AT_SUBMIT*
    Should Contain Match    ${resp}   *onap.policy.monitoring.cdap.tca.hi.lo.app*
    Should Contain Match    ${resp}   *TCA Policy Scope*

Open TCA2
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/LOOP_iYTIP_v1_0_ResourceInstanceName2_tca_2
    Should Contain Match    ${resp}   *LOOP_iYTIP_v1_0_ResourceInstanceName2_tca_2*
    Should Contain Match    ${resp}   *GENERATED_POLICY_ID_AT_SUBMIT*
    Should Contain Match    ${resp}   *dmaap.onap-message-router*
    Should Contain Match    ${resp}   *TCA Policy Scope*

Open TCA3
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/LOOP_iYTIP_v1_0_ResourceInstanceName1_tca_3
    Should Contain Match    ${resp}   *LOOP_iYTIP_v1_0_ResourceInstanceName1_tca*
    Should Contain Match    ${resp}   *GENERATED_POLICY_ID_AT_SUBMIT*
    Should Contain Match    ${resp}   *onap.policy.monitoring.cdap.tca.hi.lo.app*
    Should Contain Match    ${resp}   *TCA Policy Scope Version*

Modify MicroService Policy TCA1
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}microservicePolicyTca1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    POST Request    ${clamp_session}   /restservices/clds/v2/loop/updateMicroservicePolicy/LOOP_iYTIP_v1_0_ResourceInstanceName1_tca     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Verify Modification MicroService TCA1
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v2/loop/LOOP_iYTIP_v1_0_ResourceInstanceName1_tca
    Should Contain Match    ${resp}   *version1.11*


