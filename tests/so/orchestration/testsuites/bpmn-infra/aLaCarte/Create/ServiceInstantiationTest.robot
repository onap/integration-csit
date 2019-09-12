*** Settings ***
Documentation    Testing Create Generic ALaCarte Service Instance flow
Resource    ../../../../resources/bpmn-infra/aLaCarte/Create/ServiceInstance.robot
Resource    ../../../../resources/common/Variables.robot
Resource    ../../../../resources/common/SoVariables.robot
Resource    ../../../../resources/aai/service_instance.robot

*** Variables ***
${serv_inst_id}    shouldOverWrite
${create_service_instance_template_file}    ../../../../assets/templates/bpmn-infra/aLaCarte/Create/ServiceInstance.template

*** Settings ***
*** Test Cases ***
Create and Delete Service Alacarte GR_API
    [Tags]    Smoke    Sanity
    [Setup]   Setup GR Create Service Instance    TC_1
    log    starting create SI
    ${serv_inst_id}    ${request_id}    ${request_completion_status}    ${status_code}    ${service_body}    Create Service Instance    TC_1    ${create_service_instance_template_file}
    Should Be Equal As Strings    ${status_code}    202
    Should Be Equal As Strings    ${request_completion_status}    COMPLETE
    log    validating SI
    Validate Service Instance    Robot_SI    Robot_Test_Service_Type    Robot_Test_Subscriber_ID    Active
    Validate Owning Entity    c3f57fa8-ac7d-11e8-98d0-529269fb1459    200
    Validate Project    GR_API_OE_SO_Test200    200
    
    log    starting delete SI
    ${instance_id}    ${delete_si_request_id}    ${request_completion_status}    ${delete_service_response.status_code}    Invoke Delete Service Instance Flow    ${service_body}    ${serv_inst_id}
    Should Be Equal As Strings    ${delete_service_response.status_code}    202
    Should Be Equal As Strings    ${request_completion_status}    COMPLETE
    Validate Service Instance Not Exist By Id    ${serv_inst_id}
    Validate Owning Entity    c3f57fa8-ac7d-11e8-98d0-529269fb1459    200
    Validate Project    GR_API_OE_SO_Test200    200

    [Teardown]    Teardown GR Create Service Instance    ${serv_inst_id}