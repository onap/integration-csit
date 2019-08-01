*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           ONAPLibrary.Utilities
Library           ONAPLibrary.Templating    WITH NAME    Templating
Library           ONAPLibrary.SDC    WITH NAME    SDC

Resource          common.robot

***Variables ***
${ASDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${ASDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${ASDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}    /distribution-state
${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    /approve

${SDC_CATALOG_RESOURCE_TEMPLATE}   component_catalog_resource.jinja
${SDC_CATALOG_SERVICE_TEMPLATE}    catalog_service.jinja
${SDC_ARTIFACT_UPLOAD_TEMPLATE}    artifact_upload.jinja
${SDC_USER_REMARKS_TEMPLATE}    user_remarks.jinja
${SDC_RESOURCE_INSTANCE_TEMPLATE}    resource_instance.jinja

${ASDC_BE_ENDPOINT}  http://localhost:8080

*** Keywords ***

Create Catalog Resource Data
    [Documentation]    Creates and returns data for ASDC Catalog Resource
    [Arguments]    ${resource_name}    ${vendor_name}
    ${map}=    Create Dictionary    resource_name=${resource_name}    vendor_name=${vendor_name}
    Templating.Create Environment    sdc_catalog_resource    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_catalog_resource   ${SDC_CATALOG_RESOURCE_TEMPLATE}    ${map}
    [Return]    ${data}

Post ASDC Resource Request Unauthenticated
    [Documentation]   Makes unauthenticated Post request for ASDC Catalog resource and returns its unique id
    [Arguments]  ${data}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_RESOURCES_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}

# Based on testsuite/robot/resources/sdc_interface.robot's 'Setup SDC Catalog Resource Deployment Artifact Properties' keyword
Add Tosca Artifact To Resource
    [Documentation]  Add Tosca artifacts to given resource id
    [Arguments]   ${artifact}   ${vf_id}
    ${blueprint_data}    OperatingSystem.Get File    ${ASSETS_DIR}${artifact}.yaml
    ${payloadData}=      Base64 Encode   ${blueprint_data}
    ${dict}=    Create Dictionary  artifactLabel=${artifact}  artifactName=${artifact}.yaml   artifactType=DCAE_TOSCA  artifactGroupType=DEPLOYMENT  description=${artifact}.yaml  payloadData=${payloadData}
    Templating.Create Environment    sdc_artifact_upload    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_artifact_upload   ${SDC_ARTIFACT_UPLOAD_TEMPLATE}    ${dict}
    # POST artifactUpload to resource
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_RESOURCES_PATH}/${vf_id}/artifacts    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp}

# Directly copied from testsuite/robot/resources/sdc_interface.robot
Certify ASDC Catalog Resource
    [Documentation]    Certifies an ASDC Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${ASDC_TESTER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}   ${user_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

Add Catalog Service For Monitoring Template
    [Documentation]    Creates an ASDC Catalog Service for Monitoring Template with given name
    [Arguments]   ${service_name}
    ${map}=    Create Dictionary    service_name=${service_name}
    Templating.Create Environment    sdc_catalog_service    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_catalog_service   ${SDC_CATALOG_SERVICE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

# Based on testsuite/robot/resources/sdc_interface.robot's 'Add SDC Resource Instance' keyword
Add ASDC Resource Instance
    [Documentation]    Creates an ASDC Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}   ${resourceType}=VF
    ${milli_timestamp}=    Generate Timestamp
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    Templating.Create Environment    sdc_resource_instance    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_resource_instance   ${SDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['name']}

# All the following methods are adjusted from sdc_interface.robot

Checkin ASDC Catalog Service
    [Documentation]    Checks in an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}   ${ASDC_DESIGNER_USER_ID}

    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Request Certify ASDC Catalog Service
    [Documentation]    Requests certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certificationRequest    ${data}   ${ASDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Start Certify ASDC Catalog Service
    [Documentation]    Start certification of an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/startCertification    ${None}   ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify ASDC Catalog Service
    [Documentation]    Certifies an ASDC Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}   ${ASDC_TESTER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}

Approve ASDC Catalog Service
    [Documentation]    Approves an ASDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${ASDC_BE_ENDPOINT}    ${ASDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${ASDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}${ASDC_DISTRIBUTION_STATE_APPROVE_PATH}    ${data}   ${ASDC_GOVERNOR_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}
