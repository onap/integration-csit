*** Settings ***
Documentation     Testing PM Mapper functionality
Resource          ../../common.robot
Library           Collections
Library           json
Library           OperatingSystem
Library           RequestsLibrary
Library           HttpLibrary.HTTP
Library           String
Library           Process


*** Variables ***
${BC_URL}                     http://${DMAAPBC_IP}:8080/webapi
${CLI_EXEC_CLI}               curl http://${CBS_IP}:10000/service_component/pmmapper
${FEED1_DATA}                 { "feedName":"feed1", "feedVersion": "csit", "feedDescription":"generated for CSIT", "owner":"dgl", "asprClassification": "unclassified" }


*** Test Cases ***

Verify pmmapper configuration in consul through CBS
    [Tags]                          PM_MAPPER_01
    [Documentation]                 Verify pmmapper configuraiton in consul through CBS
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Contain                  ${cli_cmd_output.stdout}        pm-mapper-filter

Create DR Feed through Bus Controller
    [Tags]                          PM_MAPPER_02
    [Documentation]                 Create Feed on Data Router through Bus Controller
    ${resp}=                        PostCall    ${BC_URL}/feeds    ${FEED1_DATA}
    Should Be Equal As Integers     ${resp.status_code}  200

*** Keywords ***

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}