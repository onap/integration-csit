*** Settings ***
Library           json
Library           eteutils/HTTPUtils.py
Library           ONAPLibrary.Utilities

Resource          json_templater.robot
Resource          common.robot

*** Variables ***
${DCAE_PATH}    /dcae
${DCAE_CREATE_BLUEPRINT_PATH}   /SERVICE/createBluePrint
${DCAE_VFCMT_TEMPLATE}   ${ASSETS_DIR}create_vfcmt.template
${DCAE_COMPOSITION_TEMPLATE}   ${ASSETS_DIR}dcae_composition.template
${DCAE_MONITORING_CONFIGURATION_TEMPLATE}   ${ASSETS_DIR}dcae_monitoring_configuration.template
${DCAE_BE_ENDPOINT}   http://localhost:8082

*** Keywords ***

Add VFCMT To DCAE-DS
    [Documentation]   Create VFCMT with the given name and return its uuid
    [Arguments]   ${vfcmt_name}
    ${map}=    Create Dictionary    vfcmtName=${vfcmt_name}   description=VFCMT created by robot
    ${data}=   Fill JSON Template File    ${DCAE_VFCMT_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/createVFCMT     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uuid']}

Run DCAE-DS Post Request
    [Documentation]    Runs a DCAE-DS post request
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_DCAE_BE_ENDPOINT}=${DCAE_BE_ENDPOINT}
    Log    Creating session ${MY_DCAE_BE_ENDPOINT}
    ${session}=    Create Session       sdc_dcae_ds    ${MY_DCAE_BE_ENDPOINT}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Post Request    sdc_dcae_ds    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from DCAE-BE: ${resp.text}
    [Return]    ${resp}

Run DCAE-DS Put Request
    [Documentation]    Runs a DCAE-DS put request
    [Arguments]    ${data_path}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_DCAE_BE_ENDPOINT}=${DCAE_BE_ENDPOINT}
    Log    Creating session ${MY_DCAE_BE_ENDPOINT}
    ${session}=    Create Session       sdc_dcae_ds    ${MY_DCAE_BE_ENDPOINT}
    ${uuid}=    Generate UUID4
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Put Request    sdc_dcae_ds    ${data_path}    headers=${headers}
    Log    Received response from DCAE-BE: ${resp.text}
    [Return]    ${resp}

Save Composition
    [Arguments]   ${vfcmt_uuid}   ${vf_uuid}
    ${map}=    Create Dictionary    cid=${vfcmt_uuid}   vf_id=${vf_uuid}
    ${data}=   Fill JSON Template File    ${DCAE_COMPOSITION_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/saveComposition/${vfcmt_uuid}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200

Certify VFCMT
    [Arguments]   ${vfcmt_uuid}
    ${resp}=    Run DCAE-DS Put Request    ${DCAE_PATH}/certify/vfcmt/${vfcmt_uuid}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uuid']}

Add Monitoring Configuration To DCAE-DS
    [Arguments]   ${vfcmt_uuid}   ${cs_uuid}   ${vfi_name}   ${mc_name}
    ${map}=    Create Dictionary    template_uuid=${vfcmt_uuid}   service_uuid=${cs_uuid}   vfi_name=${vfi_name}  name=${mc_name}
    ${data}=   Fill JSON Template File    ${DCAE_MONITORING_CONFIGURATION_TEMPLATE}    ${map}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}/importMC     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['vfcmt']['uuid']}

Submit Monitoring Configuration To DCAE-DS
    [Arguments]   ${mc_uuid}   ${cs_uuid}   ${vfi_name}
    ${url_vfi_name}   HTTPUtils.url_encode_string  ${vfi_name}
    ${resp}=    Run DCAE-DS Post Request    ${DCAE_PATH}${DCAE_CREATE_BLUEPRINT_PATH}/${mc_uuid}/${cs_uuid}/${url_vfi_name}     ${None}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200

