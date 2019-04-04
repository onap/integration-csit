*** Settings ***
Suite Setup       Run keywords      Check k8splugin API Docker Container      Created header    Created session
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***

*** Test Cases ***
Create Definition
    [Template]      Post template
    /v1/rb/definition      create_rbdefinition.json

Get Definition
    [Template]  Get template
    /v1/rb/definition/test-rbdef
    /v1/rb/definition/test-rbdef/v1

Delete Definition
    [Template]  Delete template
    /v1/rb/definition/test-rbdef/v1

*** Keywords ***
Created session
    Create Session      multicloud_k8s_session     http://${SERVICE_IP}:${SERVICE_PORT}
    Set Suite Variable    ${suite_multicloud_k8s_session}    multicloud_k8s_session

Created header
    ${headers}=  Create Dictionary   Content-Type=application/json    Accept=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Delete template
    [Documentation]    Deletes from Definition
    [Arguments]    ${topic}
    ${resp}=         Delete Request        ${suite_multicloud_k8s_session}   ${topic}   headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    204

Post template
    [Documentation]    Create A Definition
    [Arguments]    ${topic}     ${file}
    ${data}          Get Binary File    ${CURDIR}${/}data${/}${file}
    ${resp}=         Post Request       ${suite_multicloud_k8s_session}   ${topic}   data=${data}  headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    201

Get template
    [Documentation]    Gets from Definition
    [Arguments]    ${topic}
    ${resp}=         Get Request        ${suite_multicloud_k8s_session}   ${topic}   headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

Check k8splugin API Docker Container
    [Documentation]    Checks if k8splugin docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    nexus3.onap.org:10001/onap/multicloud/k8s
