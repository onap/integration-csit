*** Settings ***
Documentation     Testing PM Mapper functionality
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           Process

Test Setup        Create Session  mapper_session  ${PMMAPPER_BASE_URL}
Test Teardown     Delete All Sessions


*** Variables ***
${CLI_EXEC_CLI_CONFIG}                   { head -n 5 | tail -1;} < /tmp/pmmapper.log
${CLI_EXEC_CLI_SUBS}                     curl -k https://${DR_PROV_IP}:8443/internal/prov
${PMMAPPER_BASE_URL}                     http://${PMMAPPER_IP}:8081
${DELIVERY_ENDPOINT}                     /delivery

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

Verify 3GPP PM Mapper responds appropriately when no metadata is provided
    [Tags]                          PM_MAPPER_10
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Missing Metadata." when no metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=1  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}    data='${EMPTY}'    headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}             400
    Should Be Equal As Strings      ${resp.content}                 Missing Metadata.

Verify 3GPP PM Mapper responds appropriately when invalid metadata is provided
    [Tags]                          PM_MAPPER_11
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Malformed Metadata." when invalid metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=1  X-ATT-DR-META='not metadata'  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}  data='${EMPTY}'  headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}             400
    Should Be Equal As Strings      ${resp.content}                 Malformed Metadata.

*** Keywords ***

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}