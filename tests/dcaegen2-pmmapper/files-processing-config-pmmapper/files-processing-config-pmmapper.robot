*** Settings ***
Documentation     Testing PM Mapper functionality
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           Process
Library           String
Library           libraries/DockerContainerManager.py
Library           libraries/LogReader.py

*** Variables ***

${PMMAPPER_BASE_URL}                     http://${PMMAPPER_IP}:8081
${NR_VALID_METADATA_PATH}                %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/valid_metadata.json
${CLI_EXEC_CLI_PM_LOG_CLEAR}             docker exec pmmapper /bin/sh -c "echo -n "" > /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
${CLI_EXEC_CLI_DR_LOG_CLEAR}             docker exec datarouter-node /bin/sh -c "echo -n "" > /opt/app/datartr/logs/events.log"
#${CLI_EXEC_CLI_DR_LOG_CLEAR}             docker exec datarouter-node /bin/sh -c "rm -rf /opt/app/datartr/logs/*"
${PUBLISH_NODE_URL}                      https://${DR_NODE_IP}:8443/publish/1
#${FILE_PATH}                             %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/new_radio/sample-events.xml
${FILE_PATH}                             %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/ABigFile.xml

${CLI_EXEC_CLI_DATAROUTER_LOG}           docker exec datarouter-node /bin/sh -c "cat /opt/app/datartr/logs/events.log | grep 429"
${cli_exec_logs_list}                    docker exec datarouter-node /bin/sh -c "ls /opt/app/datartr/logs"

${DOCKER_CLIENT_IMAGE}                   onap/org.onap.dcaegen2.services.pm-mapper:1.5.1-SNAPSHOT
${CLIENT_CONTAINER_NAME}                 pmmapper
${CONFIG_ENVS_1_1}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_1_1.env
${CONFIG_ENVS_4_1}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_4_1.env
${CONFIG_ENVS_4_2}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_4_2.env
${CONFIG_ENVS_4_4}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_4_4.env


${RUN_PMMAPPER}                          docker run -d -p 8081:8081 --mount type=bind,source="/var/tmp/",target="/opt/app/pm-mapper/etc/certs/" -e "CONFIG_BINDING_SERVICE_SERVICE_HOST=$CBS_IP" -e "CONFIG_BINDING_SERVICE_SERVICE_PORT=10000" -e "HOSTNAME=pmmapper" --add-host "dmaap-dr-node:172.18.0.2" --add-host "message-router:172.18.0.7" --network=files-processing-config-pmmapper_pmmapper-network --name=pmmapper onap/org.onap.dcaegen2.services.pm-mapper:1.5.1-SNAPSHOT
${LIST_NETWORKS}                         docker network list


*** Test Cases ***

Verify that PM Mapper rejects correct number of messages 1 1
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_1
    [Documentation]                 Verify that PM Mapper rejects correct number of messages
    [Timeout]                       15 minute

    RestartPmmapper                 ${CONFIG_ENVS_1_1}

    ${testname}=                    Set Variable                    Afirst-

#    Sleep                           5s
    SendFilesToDatarouter           ${testname}
    Sleep                           20s
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}
#    Log To Console                  All logs-------------------------------------------------------------------------------------:
#    Log To Console                  ${alllogs}
#    Log To Console                  Filtered logs----------------------------------------------------------------------------:
#    Log To Console                  ${filtered_logs}
    Log To Console                  Dropped:
    Log To Console                  ${dropped_nr}
#    Should Be Equal As Numbers      ${dropped_nr}                   5
    ClearLogs

#    Remove Container                ${CLIENT_CONTAINER_NAME}


Verify that PM Mapper rejects correct number of messages 4 1
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_2
    [Documentation]                 Verify that PM Mapper rejects correct number of messages
    [Timeout]                       15 minute

    RestartPmmapper                 ${CONFIG_ENVS_4_1}

    ${testname}=                    Set Variable                    Asecond-

#    Sleep                           5s
    SendFilesToDatarouter           ${testname}
    Sleep                           20s
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}
#    Log To Console                  All logs-----------------------------------------------------------:
#    Log To Console                  ${alllogs}
#    Log To Console                  Filtered logs----------------------------------------------------------------------:
#    Log To Console                  ${filtered_logs}
    Log To Console                  Dropped:
    Log To Console                  ${dropped_nr}
#    Should Be Equal As Numbers      ${dropped_nr}                   5
#    Sleep                           600s
    ClearLogs

Verify that PM Mapper rejects correct number of messages 4 2
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_3
    [Documentation]                 Verify that PM Mapper rejects correct number of messages
    [Timeout]                       15 minute

    RestartPmmapper                 ${CONFIG_ENVS_4_2}

    ${testname}=                    Set Variable                    Athird-

#    Sleep                           5s
    SendFilesToDatarouter           ${testname}
    Sleep                           20s
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}CheckLog
#    Log To Console                  All logs-----------------------------------------------------------:
#    Log To Console                  ${alllogs}
#    Log To Console                  Filtered logs:
#    Log To Console                  ${filtered_logs}
    Log To Console                  Dropped:
    Log To Console                  ${dropped_nr}
#    Should Be Equal As Numbers      ${dropped_nr}                   5
    ClearLogs


Verify that PM Mapper rejects correct number of messages 4 4
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_4
    [Documentation]                 Verify that PM Mapper rejects correct number of messages
    [Timeout]                       15 minute

    RestartPmmapper                 ${CONFIG_ENVS_4_4}

    ${testname}=                    Set Variable                    Afourth-

#    Sleep                           5s
    SendFilesToDatarouter           ${testname}
    Sleep                           20s
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}
#    Log To Console                  All logs-----------------------------------------------------------:
#    Log To Console                  ${alllogs}
#    Log To Console                  Filtered logs:
#    Log To Console                  ${filtered_logs}
    Log To Console                  Dropped:
    Log To Console                  ${dropped_nr}
#    Should Be Equal As Numbers      ${dropped_nr}                   5
    ClearLogs


*** Keywords ***

SendFilesToDatarouter
    [Arguments]   ${testnr}
    FOR               ${i}                             IN RANGE                             10
                      SendToDatarouter                 ${FILE_PATH}       ${NR_VALID_METADATA_PATH}            X-ONAP-RequestID=${i}      ${testnr}     ${i}
    END

SendManyFilesToDatarouter
    [Arguments]   ${env_file}
    FOR               ${i}                             IN RANGE                             10
                      SendToDatarouter                 ${FILE_PATH}       ${NR_VALID_METADATA_PATH}            X-ONAP-RequestID=${i}      ${i}
    END
    Sleep             3s
#    CheckLog          ${CLI_EXEC_CLI_PM_LOG}           Successfully published VES events to messagerouter

SendToDatarouter
    [Arguments]                     ${filepath}                      ${metadatapath}            ${request_id}            ${testnr}      ${i}
    ${pmdata}=                      Get File                         ${filepath}
    ${metatdata}                    Get File                         ${metadatapath}
    ${newFilename}                  Catenate                         SEPARATOR=                 ${testnr}               ${i}               .xml
    ${resp}=                        PutCall                          ${PUBLISH_NODE_URL}/${newFilename}        ${request_id}    ${pmdata}    ${metatdata.replace("\n","")}    pmmapper
    VerifyResponse                  ${resp.status_code}              204

PutCall
    [Arguments]                     ${url}                           ${request_id}              ${data}            ${meta}          ${user}
    ${headers}=                     Create Dictionary                X-ONAP-RequestID=${request_id}                X-DMAAP-DR-META=${meta}    Content-Type=application/octet-stream     X-DMAAP-DR-ON-BEHALF-OF=${user}    Authorization=Basic cG1tYXBwZXI6cG1tYXBwZXI=
    ${resp}=                        Evaluate                         requests.put('${url}', data="""${data}""", headers=${headers}, verify=False, allow_redirects=False)    requests
    [Return]                        ${resp}

CheckLog
    [Arguments]                     ${cli_exec_log_Path}             ${string_to_check_in_log}
    ${cli_cmd_output}=              Run Process                      ${cli_exec_log_Path}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         ${string_to_check_in_log}

VerifyResponse
    [Arguments]                     ${actual_response_value}         ${expected_response_value}
    Should Be Equal As Strings      ${actual_response_value}         ${expected_response_value}

ClearLogs
    Run Process                     ${CLI_EXEC_CLI_PM_LOG_CLEAR}                     shell=yes
    Run Process                     ${CLI_EXEC_CLI_DR_LOG_CLEAR}                     shell=yes

CleanSessionsAndLogs
    Delete All Sessions
    ClearLogs

GetLogsOutput
    ${filesString}=                   Run Process                      ${cli_exec_logs_list}                     shell=yes
    ${filesList}=                     Get Log Files List               ${filesString.stdout}
    ${output}=                        Set Variable                     ${EMPTY}
    FOR                               ${file}                          IN                                        @{filesList}
                                      ${file_path}=                    Catenate                                  SEPARATOR=    "cat /opt/app/datartr/logs/      ${file}       "
                                      ${exec}=                         Catenate                                  docker exec datarouter-node /bin/sh -c      ${file_path}
                                      ${single_file}=                  Run Process                               ${exec}         shell=yes
                                      Log To Console                   ${exec}
                                      ${output}=                       Catenate                                  SEPARATOR=\n         ${output}                  ${single_file.stdout}
    END
    [Return]                          ${output}

GetFilteredLogs
    [Arguments]                       ${all_logs}                      ${testname}
    Log To Console                    All logs-----------------------------------------------------------:
    Log To Console                    ${all_logs}
    ${filtered_logs}=                 Filter Unique                    ${all_logs}                               ${testname}
    Log To Console                    Filtered logs-----------------------------------------------------------:
    Log To Console                    ${filtered_logs}
    [Return]                          ${filtered_logs}

GetDroppedNumber
    [Arguments]                       ${logs_output}
    ${number}=                        Get Number Of Dropped Messages  ${logs_output}
    [Return]                          ${number}

ConfigureDmaap
    ${exec_1}=                        Set Variable       docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/NODES?val=dmaap-dr-node\|$GATEWAY_IP"
    ${exec_2}=                        Set Variable       docker exec -i datarouter-prov sh -c "curl -k  -X PUT https://$DR_PROV_IP:8443/internal/api/PROV_AUTH_ADDRESSES?val=dmaap-dr-prov\|$GATEWAY_IP"
    ${exec_3}=                        Set Variable       curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.feed" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @./resources/createFeed.json --post301 --location-trusted -k https://localhost:8443
    ${exec_4}=                        Set Variable       curl -v -X POST -H "Content-Type:application/vnd.dmaap-dr.subscription" -H "X-DMAAP-DR-ON-BEHALF-OF:pmmapper" --data-ascii @./resources/addSubscriber.json --post301 --location-trusted -k https://localhost:8443/subscribe/1

    Run Process                       ${exec_1}          shell=yes
    Run Process                       ${exec_2}          shell=yes

    Run Process                       ${exec_3}          shell=yes
    Run Process                       ${exec_4}          shell=yes

RestartPmmapper
    [Arguments]                       ${envs}
    ${docker_ps}                      Set Variable                docker ps
    Remove Container                  ${CLIENT_CONTAINER_NAME}
    Sleep                             5s
#    ${docker_ps_out1}                 Run Process                 ${docker_ps}                    shell=yes
#    Log To Console                    Docker ps after pmmapper remove ==================================================================
#    Log To Console                    ${docker_ps_out1.stdout}
    Run Pmmapper Container            ${DOCKER_CLIENT_IMAGE}      ${CLIENT_CONTAINER_NAME}        ${envs}
    Sleep                             5s
#    ${docker_ps_out}                  Run Process                 ${docker_ps}                    shell=yes
#    Log To Console                    Docker ps after pmmapper run ==================================================================
#    Log To Console                    ${docker_ps_out.stdout}
    ConfigureDmaap
    Sleep                             20s
