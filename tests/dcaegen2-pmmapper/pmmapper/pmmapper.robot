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
${NO_MANAGED_ELEMENT_PATH}               %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/A_no_managed_element.xml
${NO_MEASDATA_PATH}                      %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/A_no_measdata.xml
${VALID_METADATA_PATH}                   %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/valid_metadata.json
${DIFF_VENDOR_METADATA}                  %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/diff_vendor_metadata.json
${CLI_EXEC_CLI_PM_LOG}                   docker exec pmmapper /bin/sh -c "tail -5 /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
${PUBLISH_NODE_URL}                      https://${DR_NODE_IP}:8443/publish/1/A20181002.0000-1000-0015-1000_5G.xml
${PM_DATA_FILE_PATH}                     %{WORKSPACE}/tests/dcaegen2-pmmapper/pmmapper/assets/A20181002.0000-1000-0015-1000_5G.xml
${PUBLISH_CONTENT_TYPE}                  application/octet-stream
${CLI_EXEC_VENDOR_FILTER}                curl 'http://${CONSUL_IP}:8500/v1/kv/pmmapper?dc=dc1' -X PUT -H 'Accept: application/^Con' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data @$WORKSPACE/tests/dcaegen2-pmmapper/pmmapper/assets/vendor_filter_config.json
${CLI_EXEC_PM_FILTER}                    curl 'http://${CONSUL_IP}:8500/v1/kv/pmmapper?dc=dc1' -X PUT -H 'Accept: application/^Con' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data @$WORKSPACE/tests/dcaegen2-pmmapper/pmmapper/assets/pm_filter_config.json
${CLI_RESTART_PMMAPPER}                  docker restart pmmapper
${CLI_DELETE_SUB1}                       curl -i -X DELETE -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:DGL" -k https://localhost:8443/subs/1
${CLI_DELETE_SUB2}                       curl -i -X DELETE -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:DGL" -k https://localhost:8443/subs/2
${CLI_MESSAGE_ROUTER_TOPIC}              curl http://${DMAAP_MR_IP}:3904/events/topic.org.onap.dmaap.mr.test1/CG1/C1?timeout=2000

*** Test Cases ***

Verify PM Mapper Receive Configuraton From Config Binding Service
    [Tags]                          PM_MAPPER_01
    [Documentation]                 Verify 3gpp pm mapper successfully receive config data from CBS
    CheckLog                        ${CLI_EXEC_CLI_CONFIG}           Received pm-mapper configuration

Verify 3GPP PM Mapper Subscribes to Data Router
    [Tags]                          PM_MAPPER_02
    [Documentation]                 Verify 3gpp pm mapper subscribes to data router
    CheckLog                        ${CLI_EXEC_CLI_SUBS}             3gpppmmapper
    CheckLog                        ${CLI_EXEC_CLI_SUBS}             "privilegedSubscriber":true

Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Tags]                          PM_MAPPER_03
    [Documentation]                 Verify Health Check returns 200 when a REST GET request to healthcheck url
    [Timeout]                       1 minute
    ${resp}=                        Get Request                      mapper_session  ${HEALTHCHECK_ENDPOINT}
    VerifyResponse                  ${resp.status_code}              200

Verify 3GPP PM Mapper responds appropriately when no metadata is provided
    [Tags]                          PM_MAPPER_04
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Missing Metadata." when no metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=1  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}/filename    data='${EMPTY}'    headers=${headers}
    VerifyResponse                  ${resp.status_code}             400
    VerifyResponse                  ${resp.content}                 Missing Metadata.
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}          RequestID=1

Verify 3GPP PM Mapper responds appropriately when invalid metadata is provided
    [Tags]                          PM_MAPPER_05
    [Documentation]                 Verify 3GPP PM Mapper responds 400 with the message "Malformed Metadata." when invalid metadata is provided
    [Timeout]                       1 minute
    ${headers}=                     Create Dictionary               X-ONAP-RequestID=2  X-DMAAP-DR-META='not metadata'  Content-Type=application/xml
    ${resp}=                        Put Request                     mapper_session  ${DELIVERY_ENDPOINT}/filename  data='${EMPTY}'  headers=${headers}
    VerifyResponse                  ${resp.status_code}             400
    VerifyResponse                  ${resp.content}                 Malformed Metadata.
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}          RequestID=2

Verify 3GPP PM Mapper received pushed PM data from data router and publishes to message router.
    [Tags]                          PM_MAPPER_06
    [Documentation]                 Verify 3GPP PM Mapper received pushed PM data from data router and publishes to message router.
    [Timeout]                       1 minute
    ${PM_DATA}=                     Get File                         ${PM_DATA_FILE_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${resp}=                        PutCall                          ${PUBLISH_NODE_URL}     3    ${PM_DATA}    ${PUBLISH_CONTENT_TYPE}    ${valid_metatdata.replace("\n","")}    pmmapper
    VerifyResponse                  ${resp.status_code}              204
    Sleep                           10s
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           Successfully published VES events to messagerouter
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           RequestID=3
    Sleep                           10s
    CheckLog                        ${CLI_MESSAGE_ROUTER_TOPIC}      perf3gpp_gnb-Ericsson_pmMeasResult

Verify that PM Mapper logs successful when a file that contains no measdata is provided
    [Tags]                          PM_MAPPER_07
    [Documentation]                 Verify that PM Mapper logs successful when a file that contains no measdata is provided
    [Timeout]                       1 minute
    ${valid_no_measdata_content}=   Get File                         ${NO_MEASDATA_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=4  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=3  X-DMAAP-DR-META=${valid_metatdata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/A_no_measdata.xml    data=${valid_no_measdata_content}    headers=${headers}
    VerifyResponse                  ${resp.status_code}              200
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           MeasData is empty
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           RequestID=4

Verify that PM Mapper throws Event failed validation against schema error when no managed element content is provided
    [Tags]                          PM_MAPPER_08
    [Documentation]                 Verify 3gpp pm mapper responds with an error when no managed element content is provided
    [Timeout]                       1 minute
    ${no_managed_element_content}=  Get File                         ${NO_MANAGED_ELEMENT_PATH}
    ${valid_metatdata}              Get File                         ${VALID_METADATA_PATH}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=5  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=2  X-DMAAP-DR-META=${valid_metatdata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/A_no_managed_element.xml    data=${no_managed_element_content}    headers=${headers}
    VerifyResponse                  ${resp.status_code}              200
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           XML validation failed
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           RequestID=5

Verify that PM Mapper correctly identifies a file that should not be mapped based on metadata filtering.
    [Tags]                          PM_MAPPER_09
    [Documentation]                 Verify that PM Mapper correctly identifies a file that should not be mapped based on metadata filtering.
    [Timeout]                       1 minute
    ${cli_cmd_output}=              Run Process                      ${CLI_EXEC_VENDOR_FILTER}                   shell=yes
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    ${cli_cmd_output}=              Run Process                      ${CLI_DELETE_SUB1}                          shell=yes
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    ${cli_cmd_output}=              Run Process                      ${CLI_RESTART_PMMAPPER}                     shell=yes
    Sleep                           10s
    ${pm_data}=                     Get File                         ${PM_DATA_FILE_PATH}
    ${diff_vendor_metadata}=        Get File                         ${DIFF_VENDOR_METADATA}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=6  Content-Type=application/xml  X-DMAAP-DR-PUBLISH-ID=2  X-DMAAP-DR-META=${diff_vendor_metadata.replace("\n","")}
    ${resp}=                        Put Request                      mapper_session  ${DELIVERY_ENDPOINT}/A_meas_result.xml    data=${pm_data}    headers=${headers}
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           Metadata does not match any filters,
    CheckLog                        ${CLI_EXEC_CLI_PM_LOG}           RequestID=6


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

CheckLog
    [Arguments]                     ${cli_exec_log_Path}    ${string_to_check_in_log}
    ${cli_cmd_output}=              Run Process                      ${cli_exec_log_Path}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         ${string_to_check_in_log}

VerifyResponse
    [Arguments]                     ${actual_response_value}         ${expected_response_value}
    Should Be Equal As Strings      ${actual_response_value}         ${expected_response_value}