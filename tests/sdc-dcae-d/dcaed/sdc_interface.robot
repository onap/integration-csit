*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           ONAPLibrary.Utilities
Library           ONAPLibrary.Templating    WITH NAME    Templating
Library           ONAPLibrary.SDC    WITH NAME    SDC

Resource          common.robot

***Variables ***
${SDC_CATALOG_SERVICES_PATH}    /sdc2/rest/v1/catalog/services
${SDC_CATALOG_RESOURCES_PATH}    /sdc2/rest/v1/catalog/resources
${SDC_CATALOG_LIFECYCLE_PATH}    /lifecycleState
${SDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    /resourceInstance
${SDC_CATALOG_SERVICE_DISTRIBUTION_STATE_PATH}    /distribution-state
${SDC_DISTRIBUTION_STATE_APPROVE_PATH}    /approve

${SDC_DCAE_COMPONENT_MICROSERVICE_TEMPLATE}   dcae_component_microservice.jinja
${SDC_CATALOG_SERVICE_MONITORING_TEMPLATE}    catalog_service_monitoring.jinja
${SDC_ARTIFACT_UPLOAD_TEMPLATE}    artifact_upload.jinja
${SDC_USER_REMARKS_TEMPLATE}    user_remarks.jinja
${SDC_RESOURCE_INSTANCE_TEMPLATE}    resource_instance.jinja

${SDC_BE_ENDPOINT}  ${SDC_BE_PROTOCOL}://localhost:${SDC_BE_PORT}

*** Keywords ***
Onboard DCAE Microservice
    [Documentation]   Create DCAE Microservice with a given name, add Tosca artifacts to it and certify it
    ...               Return the unique_id and uuid of the certified VF
    [Arguments]   ${test_vf_name}
    ${data}=  Create SDC Catalog Resource For DCAE Component MicroService Data   ${test_vf_name}   TestVendor
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201

    ${vf_unique_id}=    Set Variable    ${resp.json()['uniqueId']}

    Add Tosca Artifact to Resource   template   ${vf_unique_id}
    Add Tosca Artifact to Resource   translate   ${vf_unique_id}
    Add Tosca Artifact to Resource   schema   ${vf_unique_id}

    ${cert_vf_unique_id}    ${cert_vf_uuid}    Certify SDC Catalog Resource   ${vf_unique_id}   ${SDC_DESIGNER_USER_ID}
    [return]   ${cert_vf_unique_id}    ${cert_vf_uuid}

Create SDC Catalog Resource For DCAE Component MicroService Data
    [Documentation]    Creates and returns data for DCAE Component MicroService SDC Catalog Resource
    [Arguments]    ${resource_name}    ${vendor_name}
    ${map}=    Create Dictionary    resource_name=${resource_name}    vendor_name=${vendor_name}
    Templating.Create Environment    sdc_dcaed    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_dcaed   ${SDC_DCAE_COMPONENT_MICROSERVICE_TEMPLATE}    ${map}
    [Return]    ${data}

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
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${vf_id}/artifacts    ${data}   ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp}

Add Catalog Service For Monitoring Template
    [Documentation]    Creates SDC Catalog Service for Monitoring Template with given name
    [Arguments]   ${service_name}
    ${map}=    Create Dictionary    service_name=${service_name}
    Templating.Create Environment    sdc_catalog_service    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_catalog_service   ${SDC_CATALOG_SERVICE_MONITORING_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

Generate Unique Postfix
    [Documentation]   Create and return unique postfix to be used in various unique names
    ${tmp_id} =   Generate Timestamp
    ${tmp_str} =   Convert To String   ${tmp_id}
    [return]    ${tmp_str}

# Directly copied from testsuite/robot/resources/sdc_interface.robot
Certify SDC Catalog Resource
    [Documentation]    Certifies an SDC Catalog Resource by its id and returns the new id
    [Arguments]    ${catalog_resource_id}    ${user_id}=${SDC_DESIGNER_USER_ID}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_RESOURCES_PATH}/${catalog_resource_id}${SDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}   ${user_id}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['uuid']}

# Based on testsuite/robot/resources/sdc_interface.robot's 'Add SDC Resource Instance' keyword
Add SDC Resource Instance
    [Documentation]    Creates an SDC Resource Instance and returns its id
    [Arguments]    ${catalog_service_id}    ${catalog_resource_id}    ${catalog_resource_name}  ${xoffset}=${0}   ${yoffset}=${0}   ${resourceType}=VF
    ${milli_timestamp}=    Generate Timestamp
    ${xoffset}=    Set Variable   ${xoffset+306}
    ${yoffset}=    Set Variable   ${yoffset+248}
    ${map}=    Create Dictionary    catalog_resource_id=${catalog_resource_id}    catalog_resource_name=${catalog_resource_name}    milli_timestamp=${milli_timestamp}   posX=${xoffset}    posY=${yoffset}    originType=${resourceType}
    Templating.Create Environment    sdc_resource_instance    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_resource_instance   ${SDC_RESOURCE_INSTANCE_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_SERVICE_RESOURCE_INSTANCE_PATH}    ${data}   ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     201
    [Return]    ${resp.json()['uniqueId']}   ${resp.json()['name']}

Create Monitoring Configuration
    [Documentation]   Create a monitoring configuration for a given service based on a previously created VFCMT
    ...               Return the unique_id and uuid of the created catalog service for the monitoring configuration
    ...               and the name of the related VFCMT instance
    [Arguments]   ${service_name}   ${vf_unique_id}   ${vf_name}
    ${cs_unique_id}   ${cs_uuid}    Add Catalog Service For Monitoring Template   ${service_name}
    ${vfi_uuid}  ${vfi_name}   Add SDC Resource Instance   ${cs_unique_id}   ${vf_unique_id}   ${vf_name}
    [return]   ${cs_unique_id}   ${cs_uuid}    ${vfi_name}

# Directly copied from testsuite/robot/resources/sdc_interface.robot
Certify And Approve SDC Catalog Service
    [Documentation]    Perform the required steps to certify and approve the given SDC catalog service
    [Arguments]    ${cs_unique_id}
    Checkin SDC Catalog Service    ${cs_unique_id}
    ${cert_cs_unique_id}=    Wait Until Keyword Succeeds   60s    10s   Certify SDC Catalog Service    ${cs_unique_id}

# All the following methods are adjusted from sdc_interface.robot

Checkin SDC Catalog Service
    [Documentation]    Checks in an SDC Catalog Service by its id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/checkin    ${data}   ${SDC_DESIGNER_USER_ID}

    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()}

Certify SDC Catalog Service
    [Documentation]    Certifies an SDC Catalog Service by its id and returns the new id
    [Arguments]    ${catalog_service_id}
    ${map}=    Create Dictionary    user_remarks=Robot remarks
    Templating.Create Environment    sdc_user_remarks    ${ASSETS_DIR}
    ${data}=   Templating.Apply Template    sdc_user_remarks   ${SDC_USER_REMARKS_TEMPLATE}    ${map}
    ${resp}=    SDC.Run Post Request    ${SDC_BE_ENDPOINT}    ${SDC_CATALOG_SERVICES_PATH}/${catalog_service_id}${SDC_CATALOG_LIFECYCLE_PATH}/certify    ${data}   ${SDC_DESIGNER_USER_ID}
    Should Be Equal As Strings  ${resp.status_code}     200
    [Return]    ${resp.json()['uniqueId']}
