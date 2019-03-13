*** Settings ***
Suite Setup       Run keywords      SMS Check SMS API Docker Container      Created header    Created session
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***

*** Test Cases ***
Create Domain
    [Template]      Post template
    /v1/sms/domain      create_domain.json
    /v1/sms/domain/curltestdomain/secret        create_secret.json

Get information from Domain
    [Template]  Get template
    /v1/sms/quorum/status
    /v1/sms/domain/curltestdomain/secret
    /v1/sms/domain/curltestdomain/secret/curltestsecret1

Delete from Domain
    [Template]  Delete template
    /v1/sms/domain/curltestdomain/secret/curltestsecret1
    /v1/sms/domain/curltestdomain

*** Keywords ***
Created session
    Create Session      aaf_sms_session     ${SMS_HOSTNAME}:${SMS_PORT}
    Set Suite Variable    ${suite_aaf_sms_session}    aaf_sms_session

Created header
    ${headers}=  Create Dictionary   Content-Type=application/json    Accept=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Delete template
    [Documentation]    Deletes from Domain
    [Arguments]    ${topic}
    ${resp}=         Delete Request        ${suite_aaf_sms_session}   ${topic}   headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    204

Post template
    [Documentation]    Create A Domain/Secret Names
    [Arguments]    ${topic}     ${file}
    ${data}          Get Binary File    ${CURDIR}${/}data${/}${file}
    ${resp}=         Post Request       ${suite_aaf_sms_session}   ${topic}   data=${data}  headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    201

Get template
    [Documentation]    Gets from Domain
    [Arguments]    ${topic}
    ${resp}=         Get Request        ${suite_aaf_sms_session}   ${topic}   headers=${suite_headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    Should Be Equal As Integers    ${resp.status_code}    200

SMS Check SMS API Docker Container
    [Documentation]    Checks if SMS docker container is running
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    nexus3.onap.org:10001/onap/aaf/sms
