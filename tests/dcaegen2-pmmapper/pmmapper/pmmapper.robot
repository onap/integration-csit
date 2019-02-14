*** Settings ***
Documentation     Testing PM Mapper functionality
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           Process


*** Variables ***
${CLI_EXEC_CLI}                     curl -k https://${DR_PROV_IP}:8443/internal/prov

*** Test Cases ***

Verify 3GPP PM Mapper Subscribes to Data Router
    [Tags]                          PM_MAPPER_01
    [Documentation]                 Verify 3gpp pm mapper subscribes to data router
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        "3gpppmmapper"

*** Keywords ***

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}