*** Settings ***
Documentation     Testing PM Mapper functionality
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           Process


*** Variables ***
${GLOBAL_APPLICATION_ID}                 robot-ves
${CLI_EXEC_CLI}                          curl http://${CBS_IP}:10000/service_component/pmmapper


*** Test Cases ***

Verify pmmapper configuration in consul through CBS
    [Tags]                          PM_MAPPER_01
    [Documentation]                 Verify pmmapper configuraiton in consul through CBS
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Contain                  ${cli_cmd_output.stdout}        pm-mapper-filter