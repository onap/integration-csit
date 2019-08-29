*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    HttpLibrary.HTTP
Library    OperatingSystem
Library    BuiltIn
Library    String
Library    CSVLibrary
Resource    ../../../json_templater.robot
Resource    ../../../SoKeywords.robot
Resource    ../../../common/SoVariables.robot
Resource    ../../../so_interface.robot
Resource    ../../../aai/service_instance.robot
Resource    ../../../common/Variables.robot
Resource          ../../../properties/tenant.robot
Resource          ../../../properties/cloudRegion.robot

*** Variables ***
${data_file}                                     ../../../../data/bpmn-infra/aLaCarte/ServiceInstance.csv
${create_customer_template_file}                 tests/so/orchestration/assets/templates/aai/add_customer_required_fields.template
${create_service_subscription_template_file}     tests/so/orchestration/assets/templates/aai/service_subscription_required_fields.template
${create_service_model_template_file}            tests/so/orchestration/assets/templates/aai/service_model.template
${serviceInstanceDictionary}
${serv_inst_id}
${serv_inst_tc_code}
${SUBSCRIBER_TYPE}    CUST
${EXPECTED_ORCHESTRATION_STATUS}    Active
${tenant_json}    tests/so/orchestration/assets/templates/setup_tenant.json
${cloud_region_json}    tests/so/orchestration/assets/templates/setup_cloud_region.json
${NOT_APPLICABLE}    NA

*** Keywords ***
    
Setup GR Create Service Instance
    [Arguments]    ${serv_inst_tc_code}
    ${serviceInstanceDictionary}    Read CSV Data And Create Dictionary    ${CURDIR}/${data_file}
    Set Suite Variable    ${serviceInstanceDictionary}
    Set Suite Variable    ${serv_inst_tc_code}

    Setup Cloud Region
    Setup Tenant in AAI
    
    ${create_service_instance_data}	    Get From Dictionary    ${serviceInstanceDictionary}    ${serv_inst_tc_code}
    
    ${SUBSCRIBER_ID}    Get From Dictionary    ${create_service_instance_data}   subscriberId
    Setup Customer    ${SUBSCRIBER_ID}
    ${SUBSCRIPTION_SERVICE_TYPE}    Get From Dictionary    ${create_service_instance_data}   serviceType
    Setup Service Subscription    ${SUBSCRIBER_ID}    ${SUBSCRIPTION_SERVICE_TYPE}

    Setup Service Model in A&AI    ${serviceInstanceDictionary}    ${serv_inst_tc_code}

Teardown GR Create Service Instance
    [Arguments]    ${service_instance_id}
    Delete Service Instance by Id    ${service_instance_id}

      
Setup Cloud Region
    [Documentation]    Setup the cloud region in AAI
    
    ${cloud_region_data}    Create Dictionary    cloudOwner=${cloudOwner}    cloudRegionId=${cloudRegionId}    cloudType=${cloudType}
                                          ...    ownerDefinedType=${ownerDefinedType}    cloudRegionVersion=${cloudRegionVersion}    cloudZone=${cloudZone}
                                          ...    complexName=${complexName}    sriovAutomation=${sriovAutomation}
    ${create_cloud_region_json}    Fill JSON Template File    ${cloud_region_json}    ${cloud_region_data}
    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}/cloud-infrastructure/cloud-regions/cloud-region/${cloudOwner}/${cloudRegionId}    ${create_cloud_region_json}
    
    ${json}=    OperatingSystem.Get File    tests/so/orchestration/assets/templates/gr-api/PhysicalServerCreate.json
    ${returned_json}=  To Json    ${json}
    Run A&AI Put Request    aai/v14/cloud-infrastructure/pservers/pserver/rdm52r19c001    ${returned_json}
    
Setup Tenant in AAI
    [Documentation]    Setup the tenant in AAI
    
    ${tenant_data}    Create Dictionary    tenantId=${aai_tenant_Id}    tenantName=${aai_tenant_name}    
    ${create_tenant_json}    Fill JSON Template File    ${tenant_json}    ${tenant_data}    
    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}/cloud-infrastructure/cloud-regions/cloud-region/${cloudOwner}/${cloudRegionId}/tenants/tenant/${aai_tenant_Id}    ${create_tenant_json}

Setup Customer
    [Documentation]    Creates customer for use in tests
    [Arguments]    ${SUBSCRIBER_ID}
    
    ${create_customer_data}    Create Dictionary    global_customer_id=${SUBSCRIBER_ID}    subscriber_name=${SUBSCRIBER_ID}    subscriber_type=${SUBSCRIBER_TYPE}
    Set Suite Variable    ${create_customer_data}
    ${create_customer_json}    Fill JSON Template File    ${create_customer_template_file}    ${create_customer_data}

    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}/business/customers/customer/${SUBSCRIBER_ID}    ${create_customer_json}

Setup Service Subscription
    [Documentation]    Creates service subscription for use in tests
    [Arguments]    ${SUBSCRIBER_ID}    ${SUBSCRIPTION_SERVICE_TYPE}
    ${create_service_subscription_data}    Create Dictionary    service_type=${SUBSCRIPTION_SERVICE_TYPE}
    Set Suite Variable    ${create_service_subscription_data}
    ${create_service_subscription_json}    Fill JSON Template File    ${create_service_subscription_template_file}    ${create_service_subscription_data}

    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}/business/customers/customer/${SUBSCRIBER_ID}/service-subscriptions/service-subscription/${SUBSCRIPTION_SERVICE_TYPE}    ${create_service_subscription_json}

Setup Service Model in A&AI
    [Arguments]    ${serviceeDictionary}    ${serv_inst_tc_code}

    ${create_service_instance_data}	    Get From Dictionary    ${serviceInstanceDictionary}    ${serv_inst_tc_code}
    ${modelInvariantId}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelInvariantId
    ${modelVersionId}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelNameVersionId
    ${modelName}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelName
    ${modelType}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelType
    ${modelVersion}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelVersion
    ${modelDescription}    Get From Dictionary    ${create_service_instance_data}   serviceInstModelDescription
    Setup Model in AAI    ${modelInvariantId}    ${modelType}    ${modelVersionId}    ${modelName}    ${modelVersion}    ${modelDescription}
  
Setup Model in AAI
    [Documentation]    Setup Model in AAI for use in tests
    [Arguments]    ${modelInvariantId}    ${modelType}    ${modelVersionId}    ${modelName}    ${modelVersion}    ${modelDescription}
    ${create_service_model_data}    Create Dictionary    modelInvariantId=${modelInvariantId}    modelType=${modelType}    modelVersionId=${modelVersionId}
                                                        ...    modelName=${modelName}    modelVersion=${modelVersion}    modelDescription=${modelDescription}
    ${create_service_model_json}    Fill JSON Template File    ${create_service_model_template_file}    ${create_service_model_data}

    Run A&AI Put Request    ${VERSIONED_INDEX_PATH}/service-design-and-creation/models/model/${modelInvariantId}    ${create_service_model_json}
  
   
Create Service Instance
    [Documentation]    Test Template for CreateServiceInstanceInfra
    [Arguments]    ${serv_inst_tc_code}    ${payload_template}
    log    in create si sub
    Log    ${serv_inst_tc_code}
    Log    ${payload_template}
    ${create_service_instance_data}	    Get From Dictionary    ${serviceInstanceDictionary}    ${serv_inst_tc_code}
    Log    create si data
    Log    ${create_service_instance_data}
    Log    ${CURDIR}/${payload_template}
    Log    ${create_service_instance_data}
    Log    ready to fill
    ${service_body}=    Fill JSON Template File    ${CURDIR}/${payload_template}    ${create_service_instance_data}
    Log    got service body
    Log    ${service_body}
    Log    after service body
    ${serv_inst_id}    ${request_id}    ${request_completion_status}    ${status_code}    Invoke Create Service Instance Flow    ${service_body}
    [Return]    ${serv_inst_id}    ${request_id}    ${request_completion_status}    ${status_code}    ${service_body}



Invoke Create Service Instance Flow
    [Documentation]    Create Service Instance
    [Arguments]    ${service_body}
    log    invoking
    ${create_service_response}  Run SO Post request    ${SO_REST_URI_CREATE_SERVICE}    ${service_body}
    log    retunred ${create_service_response}
    Return From Keyword If    ${create_service_response.status_code} != ${HTTP_ACCEPTED}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${create_service_response.status_code}
    ${request_id_string}    Get Json Value    ${create_service_response.content}    /requestReferences/requestId
    ${request_id}    Get Substring    ${request_id_string}    1    -1
    ${instance_id_string}    Get Json Value    ${create_service_response.content}    /requestReferences/instanceId
    ${instance_id}    Get Substring    ${instance_id_string}    1    -1
    Log    ${instance_id}
    ${request_completion_status}    ${orchestration_failure_message}    Run Keyword If    ${create_service_response.status_code} == ${HTTP_ACCEPTED}
                                                   ...    Poll Orchestration Request    ${request_id}

    [Return]    ${instance_id}    ${request_id}    ${request_completion_status}    ${create_service_response.status_code}
 
 Invoke Delete Service Instance Flow
    [Documentation]    Delete a service instance.
    [Arguments]    ${service_body}    ${service_instance}

    ${delete_service_response}    Run SO Delete request    ${SO_REST_URI_DELETE_SERVICE}/${service_instance}    data=${service_body}

    Return From Keyword If    ${delete_service_response.status_code} != ${HTTP_ACCEPTED}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${delete_service_response.status_code}

    ${request_id_string}    Get Json Value    ${delete_service_response.content}    /requestReferences/requestId
    ${request_id}    Get Substring    ${request_id_string}    1    -1
    ${instance_id_string}    Get Json Value    ${delete_service_response.content}    /requestReferences/instanceId
    ${instance_id}    Get Substring    ${instance_id_string}    1    -1

    ${request_completion_status}    ${orchestration_failure_message}    Run Keyword If    ${delete_service_response.status_code} == ${HTTP_ACCEPTED}
                                                   ...    Poll Orchestration Request    ${request_id}

    [Return]    ${instance_id}    ${request_id}    ${request_completion_status}    ${delete_service_response.status_code}
