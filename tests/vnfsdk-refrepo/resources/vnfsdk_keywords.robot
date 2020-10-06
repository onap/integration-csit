*** Settings ***
Resource          ./vnfsdk_properties.robot

Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           RequestsLibrary
Library           json

*** Keywords ***

Validate CSAR usign Post request
    [Documentation]    Perform DCAE Node Health Check
    [Arguments]    ${csar_name}  ${execution_json}
    ${response}=   Run   curl -s --location --request POST '${base_url}/vtp/executions' --header 'Content-Type: multipart/form-data' --header 'Accept: application/json' --form 'file=@${csarpath}/${csar_name}' --form 'executions=${execution_json}'
    ${response}=    String.Replace String    ${response}    \\n   ${SPACE}
    [Return]     ${response}

Get validation resoult using GET request
    [Documentation]    Perform DCAE Node Health Check
    [Arguments]    ${requestId}
    ${response}=   Run   curl -s --location --request GET '${base_url}/vtp/executions?requestId=${requestId}' --header 'Accept: application/json'
    ${response}=    String.Replace String    ${response}    \\n   ${SPACE}
    [Return]     ${response}
