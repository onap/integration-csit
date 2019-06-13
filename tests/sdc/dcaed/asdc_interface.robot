*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           eteutils/UUID.py

Resource          common.robot

***Variables ***
${ASDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${ASDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${ASDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}    /distribution-state
${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    /approve

${ASDC_CATALOG_RESOURCE_TEMPLATE}   ${ASSETS_DIR}component_catalog_resource.template
${ASDC_CATALOG_SERVICE_TEMPLATE}    ${ASSETS_DIR}catalog_service.template
${ASDC_ARTIFACT_UPLOAD_TEMPLATE}    ${ASSETS_DIR}artifact_upload.template
${ASDC_USER_REMARKS_TEMPLATE}    ${ASSETS_DIR}user_remarks.template
${DCAE_VFCMT_TEMPLATE}   ${ASSETS_DIR}create_vfcmt.template
${DCAE_COMPOSITION_TEMPLATE}   ${ASSETS_DIR}dcae_composition.template
${DCAE_MONITORING_CONFIGURATION_TEMPLATE}   ${ASSETS_DIR}dcae_monitoring_configuration.template
${ASDC_RESOURCE_INSTANCE_TEMPLATE}    ${ASSETS_DIR}resource_instance.template

${ASDC_BE_ENDPOINT}  http://localhost:8080

*** Keywords ***

Create Catalog Resource Data
    [Documentation]    Creates and returns data for ASDC Catalog Resource
    [Arguments]    ${resource_name}    ${vendor_name}
    ${map}=    Create Dictionary    resource_name=${resource_name}    vendor_name=${vendor_name}
    ${data}=   json_templater.Fill JSON Template File    ${ASDC_CATALOG_RESOURCE_TEMPLATE}    ${map}
    [Return]    ${data}

# Based on testsuite/robot/resources/asdc_interface.robot's 'Post ASDC Resource Request' keyword
Post ASDC Resource Request Unauthenticated
    [Documentation]   Makes unauthenticated Post request for ASDC Catalog resource and returns its unique id
    [Arguments]  ${data}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_RESOURCES_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

# Based on testsuite/robot/resources/asdc_interface.robot's 'Run ASDC Post Request' keyword
Run ASDC Post Request Unauthenticated
    [Documentation]    Runs an ASDC Post request without authentication and returns the HTTP response
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}=    Post Request    asdc    ${data_path}     data=${data}    headers=${headers}
    Log    Received response from asdc ${resp.text}
    [Return]    ${resp}

# Based on testsuite/robot/resources/asdc_interface.robot's 'Run ASDC MD5 Post Request' keyword
Run ASDC MD5 Post Request Unauthenticated
    [Documentation]    Runs an ASDC post request with MD5 Checksum header without authentication and returns the HTTP response
    [Arguments]    ${data_path}    ${data}    ${user}=${ASDC_DESIGNER_USER_ID}   ${MY_ASDC_BE_ENDPOINT}=${ASDC_BE_ENDPOINT}
    Log    Creating session ${MY_ASDC_BE_ENDPOINT}
    ${session}=    Create Session       asdc    ${MY_ASDC_BE_ENDPOINT}
    ${uuid}=    Generate UUID
    ${data_string}=   Evaluate    json.dumps(${data})     json
    ${md5checksum}=   Evaluate    md5.new('''${data_string}''').hexdigest()   modules=md5
    ${base64md5checksum}=  Evaluate     base64.b64encode("${md5checksum}")     modules=base64
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json    USER_ID=${user}    X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}   Content-MD5=${base64md5checksum}
    ${resp}=    Post Request    asdc    ${data_path}     data=${data}    headers=${headers}
    Log   Received response from asdc: ${resp.text}
    [Return]    ${resp}

# Based on testsuite/robot/resources/asdc_interface.robot's 'Setup SDC Catalog Resource Deployment Artifact Properties' keyword
Add Tosca Artifact To Resource
    [Documentation]  Add Tosca artifacts to given resource id
    [Arguments]   ${artifact}   ${vf_id}
    ${blueprint_data}    OperatingSystem.Get File    ${ASSETS_DIR}${artifact}.yaml
    ${payloadData}=   Evaluate   base64.b64encode('''${blueprint_data}'''.encode('utf-8'))   modules=base64
    ${dict}=    Create Dictionary  artifactLabel=${artifact}  artifactName=${artifact}.yaml   artifactType=DCAE_TOSCA  artifactGroupType=DEPLOYMENT  description=${artifact}.yaml  payloadData=${payloadData}
    ${data}=   Fill JSON Template File    ${ASDC_ARTIFACT_UPLOAD_TEMPLATE}    ${dict}
    # POST artifactUpload to resource
    ${resp}=    Run ASDC MD5 Post Request Unauthenticated    ${ASDC_CATALOG_RESOURCES_PATH}/${vf_id}/artifacts    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp}

# Directly copied from testsuite/robot/resources/asdc_interface.robot
Certify ASDC Catalog Resource
    [Documentation]    Certifies an ASDC Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${ASDC_TESTER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${user_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

Add Catalog Service For Monitoring Template
    [Documentation]    Creates an ASDC Catalog Service for Monitoring Template with given name
    [Arguments]   ${service_name}
    ${map}=    Create Dictionary    service_name=${service_name}
    ${data}=   Fill JSON Template File    ${ASDC_CATALOG_SERVICE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}    ${data}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

# Based on testsuite/robot/resources/asdc_interface.robot's 'Add ASDC Resource Instance' keyword
Add ASDC Resource Instance
    [Documentation]    Creates an ASDC Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}   ${resourceType}=VF
    ${milli_timestamp}=    Generate MilliTimestamp UUID
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    ${data}=   Fill JSON Template File    ${ASDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}     ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['name']}

# Adjusted from asdc_interface.robot

Checkin ASDC Catalog Service
    [Documentation]    Checks in an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify ASDC Catalog Service
    [Documentation]    Requests certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}    ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify ASDC Catalog Service
    [Documentation]    Start certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify ASDC Catalog Service
    [Documentation]    Certifies an ASDC Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}    ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Approve ASDC Catalog Service
    [Documentation]    Approves an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    ${data}=   Fill JSON Template File    ${ASDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    Run ASDC Post Request Unauthenticated    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    ${data}    ${ASDC_GOVERNOR_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

