*** Settings ***
Documentation    Suite description
Library       OperatingSystem
Library       RequestsLibrary
Library       json
Library       RequestsLibrary
*** Variables ***
&{headers}=      Content-Type=application/json  Accept=application/json
*** Keywords ***
Verify Docker RC Status
    [Documentation]  Method to verify whether docker instance is up and running
    [Arguments]  ${process_name}
    ${rc}    ${output}=    Run and Return RC and Output    docker ps
    Log To Console              *********************
    Log To Console              retrurn_code = ${rc}
    Log To Console              output = ${output}
    Should Be Equal As Integers    ${rc}    0
    Should Contain    ${output}    ${process_name}

Http Get
    [Documentation]  Wrapper for Http GET
    [Arguments]  ${host}    ${restUrl}
    Create Session   optf-osdf            ${host}
    ${resp}=         Get Request        optf-osdf   ${restUrl}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    [Return]  ${resp}

Http Post
    [Documentation]  Wrapper for Http POST
    [Arguments]  ${host}    ${restUrl}    ${auth}    ${data}
    ${pci_auth}=    Create List    ${auth['username']}  ${auth['password']}
    Create Session   optf-osdf            ${host}    headers=${headers}   auth=${pci_auth}
    ${resp}=         Post Request        optf-osdf   ${restUrl}    data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    [Return]  ${resp}

Http Put
    [Documentation]  Wrapper for Http PUT
    [Arguments]  ${host}    ${restUrl}    ${auth}    ${data}
    ${pci_auth}=    Create List    ${auth['username']}  ${auth['password']}
    Create Session   optf-osdf            ${host}    headers=${headers}   auth=${pci_auth}
    ${resp}=         Put Request        optf-osdf   ${restUrl}    data=${data}     headers=${headers}
    Log To Console              *********************
    Log To Console              response = ${resp}
    Log To Console              body = ${resp.text}
    [Return]  ${resp}