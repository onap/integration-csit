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
${HEALTHCHECK_ENDPOINT}                  /healthcheck
${NO_MANAGED_ELEMENT_PATH}               %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/no_managed_element.xml
${NO_MEASDATA_PATH}                      %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/no_measdata.xml
${MEASD_RESULT_PATH}                     %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/meas_result.xml
${VALID_METADATA_PATH}                   %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/valid_metadata.json
${CLI_EXEC_CLI_PM_LOG}                   docker exec pmmapper /bin/sh -c "tail -5 /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
${PUBLISH_NODE_URL}                      https://${DR_NODE_IP}:8443/publish/1/pm.xml
${PM_DATA_FILE_PATH}                     %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/A20181002.0000-1000-0015-1000_5G.xml
${PUBLISH_CONTENT_TYPE}                  application/octet-stream


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

Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Tags]                          PM_MAPPER_03
    [Documentation]                 Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Timeout]                       1 minute
    ${resp}=                        Get Request                      mapper_session  ${HEALTHCHECK_ENDPOINT}
    Should Be Equal As Strings      ${resp.status_code}              200

Verify 3GPP PM Mapper responds appropriately when no metadata is provided
    [Tags]                          PM_MAPPER_04
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Missing Metadata." when no metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=1  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}/filename    data='${EMPTY}'    headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}             400
    Should Be Equal As Strings      ${resp.content}                 Missing Metadata.

Verify 3GPP PM Mapper responds appropriately when invalid metadata is provided
    [Tags]                          PM_MAPPER_05
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Malformed Metadata." when invalid metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=2  X-DMAAP-DR-META='not metadata'  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}/filename  data='${EMPTY}'  headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}             400
    Should Be Equal As Strings      ${resp.content}                 Malformed Metadata.

Verify 3GPP PM Mapper received pushed PM data from Data Router
    [Tags]                          PM_MAPPER_06
    [Documentation]                 Verify 3GPP PM Mapper received pushed PM data from Data Router
    [Timeout]                       1 minute
    ${PM_DATA}=                     Get File                         ${PM_DATA_FILE_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${resp}=                        PutCall                          ${PUBLISH_NODE_URL}     3    ${PM_DATA}    ${PUBLISH_CONTENT_TYPE}    ${valid_metatdata.replace("\n","")}    pmmapper
    Log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    Sleep     10s
    ${cli_cmd_output}=              Run Process                      ${CLI_EXEC_CLI_PM_LOG}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         XML validation successful

Verify that PM Mapper logs successful when a file that contains measdata is provided
    [Tags]                          PM_MAPPER_07
    [Documentation]                 Verify that PM Mapper logs successful when a file that contains measdata is provided
    [Timeout]                       1 minute
    ${valid_meas_result_content}=   Get File                         ${MEASD_RESULT_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=4  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=4  X-DMAAP-DR-META=${valid_metatdata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/filename    data=${valid_meas_result_content}    headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}              200
    ${cli_cmd_output}=              Run Process                      ${CLI_EXEC_CLI_PM_LOG}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         XML validation successful

Verify that PM Mapper logs successful when a file that contains no measdata is provided
    [Tags]                          PM_MAPPER_08
    [Documentation]                 Verify that PM Mapper logs successful when a file that contains no measdata is provided
    [Timeout]                       1 minute
    ${valid_no_measdata_content}=   Get File                         ${NO_MEASDATA_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=5  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=3  X-DMAAP-DR-META=${valid_metatdata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/filename    data=${valid_no_measdata_content}    headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}              200
    ${cli_cmd_output}=              Run Process                      ${CLI_EXEC_CLI_PM_LOG}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         XML validation successful

Verify that PM Mapper throws Event failed validation against schema error when no managed element content is provided
    [Tags]                          PM_MAPPER_09
    [Documentation]                 Verify 3gpp pm mapper responds with an error when no managed element content is provided
    [Timeout]                       1 minute
    ${no_managed_element_content}=  Get File                         ${NO_MANAGED_ELEMENT_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=6  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=2  X-DMAAP-DR-META=${valid_metatdata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/filename    data=${no_managed_element_content}    headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}              200
    ${cli_cmd_output}=              Run Process                      ${CLI_EXEC_CLI_PM_LOG}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         XML validation failed


*** Keywords ***

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

PutCall
    [Arguments]      ${url}       ${request_id}       ${data}            ${content_type}           ${meta}          ${user}
    ${headers}=      Create Dictionary   X-ONAP-RequestID=${request_id}    X-DMAAP-DR-META=${meta}    Content-Type=${content_type}   X-DMAAP-DR-ON-BEHALF-OF=${user}    Authorization=Basic cG1tYXBwZXI6cG1tYXBwZXI=
    ${resp}=         Evaluate            requests.put('${url}', data="""${data}""", headers=${headers}, verify=False, allow_redirects=False)    requests
    [Return]         ${resp}
