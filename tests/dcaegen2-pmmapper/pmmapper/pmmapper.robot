*** Settings ***
Documentation     Testing PM Mapper functionality
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           Process


*** Variables ***
${CLI_EXEC_CLI_CONFIG}                   { head -n 5 | tail -1;} < /tmp/pmmapper.log
${CLI_EXEC_CLI_SUBS}                     curl -k https://${DR_PROV_IP}:8443/internal/prov

*** Test Cases ***

Verify PM Mapper Receive Configuraton From Config Binding Service
    [Tags]                          PM_MAPPER_01
    [Documentation]                 Verify 3gpp pm mapper successfully receive config data from CBS
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_CONFIG}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        Received pm-mapper configuration

Verify 3GPP PM Mapper Subscribes to Data Router
    [Tags]                          PM_MAPPER_02
    [Documentation]                 Verify 3gpp pm mapper subscribes to data router
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_SUBS}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        3gpppmmapper

*** Keywords ***

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}