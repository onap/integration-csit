*** Settings ***
Library       RequestsLibrary
Library       Process

*** Variables ***

${cli_exec}    docker exec cli onap
${cli_exec_cli_10_version}    docker exec cli bash -c "export OPEN_CLI_PRODUCT_IN_USE=open-cli && onap --version"

*** Test Cases ***
Liveness Test
    [Documentation]        Check cli liveness check
    Create Session         cli              https://${CLI_IP}:443
    CheckUrl               cli              /

Check Cli Version Default
    [Documentation]    check cli default version
    ${cli_cmd_output}=    Run Process   ${cli_exec_cli_10_version}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    : open-cli


*** Keywords ***
CheckUrl
    [Arguments]                   ${session}  ${path}
    ${resp}=                      Get Request          ${session}  ${path}
    Should Be Equal As Integers   ${resp.status_code}  200
