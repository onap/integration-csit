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

${NR_VALID_METADATA_PATH}                %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/valid_metadata.json
${CLI_EXEC_CLI_PM_LOG_CLEAR}             docker exec pmmapper /bin/sh -c "echo -n "" > /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
${PUBLISH_NODE_URL}                      https://${DR_NODE_IP}:8443/publish/1
${CLI_EXEC_LOGS_LIST}                    docker exec datarouter-node /bin/sh -c "ls /opt/app/datartr/logs"
${DOCKER_CLIENT_IMAGE}                   nexus3.onap.org:10001/onap/org.onap.dcaegen2.services.pm-mapper:latest
${CLIENT_CONTAINER_NAME}                 pmmapper
${FILE_PATH}                             %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/ABigFile.xml
${CONFIG_ENVS_1_1}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_1_1.env
${CONFIG_ENVS_4_1}                       %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_4_1.env
${CONFIG_ENVS_10_1}                      %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_10_1.env
${CONFIG_ENVS_1_10}                      %{WORKSPACE}/tests/dcaegen2-pmmapper/files-processing-config-pmmapper/assets/config_1_10.env

*** Test Cases ***

Verify that PM Mapper rejects 6-9 messages when limitRate is 1 and threads count is 1
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_1
    [Documentation]                 Verify that PM Mapper rejects 6-9/10 messages. Configuration: limitRate=1, threadsCount=1
    [Timeout]                       15 minute

    RestartPmmapper                 ${CONFIG_ENVS_1_1}

    ${testname}=                    Set Variable                    Afirst-

    SendFilesToDatarouter           ${testname}
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}

    Sleep                           40s
    ${isCorrectDroppedCount}=       Evaluate  ${5} < ${dropped_nr} < ${10}
    SavePmMapperLogsAndDroppedCount  config_1_1  ${dropped_nr}
    Should Be True                  ${isCorrectDroppedCount}  Pm-mapper drop: ${dropped_nr} messages. Expected drop count: 6-9
    ClearLogs

Verify that PM Mapper rejects 0 messages when limitRate is 10 and threads count is 1
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_2
    [Documentation]                 Verify that PM Mapper rejects 0/10 messages. Configuration: limitRate=10, threadsCount=1
    [Timeout]                       25 minute

    RestartPmmapper                 ${CONFIG_ENVS_10_1}

    ${testname}=                    Set Variable                    Athird-

    SendFilesToDatarouter           ${testname}
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}

    Sleep                           15s
    SavePmMapperLogsAndDroppedCount  config_10_1  ${dropped_nr}
    Should Be Equal As Numbers      ${dropped_nr}   0   Pm-mapper drop: ${dropped_nr} messages. Expected drop count: 0
    ClearLogs

Verify that PM Mapper rejects 0 messages when limitRate is 1 and threads count is 10
    [Tags]                          FILES_PROCESSING_CONFIG_PM_MAPPER_3
    [Documentation]                 Verify that PM Mapper rejects 0/10 messages. Configuration: limitRate=1, threadsCount=10
    [Timeout]                       25 minute

    RestartPmmapper                 ${CONFIG_ENVS_1_10}

    ${testname}=                    Set Variable                    Afourth-

    SendFilesToDatarouter           ${testname}
    ${alllogs}=                     GetLogsOutput
    ${filtered_logs}=               GetFilteredLogs                 ${alllogs}                                    ${testname}
    ${dropped_nr}=                  GetDroppedNumber                ${filtered_logs}

    Sleep                           15s
    SavePmMapperLogsAndDroppedCount  config_1_10  ${dropped_nr}
    Should Be Equal As Numbers      ${dropped_nr}   0   Pm-mapper drop: ${dropped_nr} messages. Expected drop count: 0
    ClearLogs

*** Keywords ***

SendFilesToDatarouter
    [Arguments]                     ${testnr}
    FOR                             ${i}                             IN RANGE                     10
                                    SendToDatarouter                 ${FILE_PATH}                 ${NR_VALID_METADATA_PATH}                 X-ONAP-RequestID=${i}        ${testnr}         ${i}
    END
    Sleep                           20s

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

VerifyResponse
    [Arguments]                     ${actual_response_value}         ${expected_response_value}
    Should Be Equal As Strings      ${actual_response_value}         ${expected_response_value}

ClearLogs
    Run Process                     ${CLI_EXEC_CLI_PM_LOG_CLEAR}                     shell=yes

GetLogsOutput
    ${filesString}=                   Run Process                      ${CLI_EXEC_LOGS_LIST}                     shell=yes
    ${filesList}=                     Get Log Files List               ${filesString.stdout}
    ${output}=                        Set Variable                     ${EMPTY}
    FOR                               ${file}                          IN                                        @{filesList}
                                      ${file_path}=                    Catenate                                  SEPARATOR=    "cat /opt/app/datartr/logs/      ${file}       "
                                      ${exec}=                         Catenate                                  docker exec datarouter-node /bin/sh -c      ${file_path}
                                      ${single_file}=                  Run Process                               ${exec}         shell=yes
                                      ${output}=                       Catenate                                  SEPARATOR=\n         ${output}                  ${single_file.stdout}
    END
    [Return]                          ${output}

GetFilteredLogs
    [Arguments]                       ${all_logs}                      ${testname}
    ${filtered_logs}=                 Filter Unique                    ${all_logs}                               ${testname}
    [Return]                          ${filtered_logs}

GetDroppedNumber
    [Arguments]                       ${logs_output}
    ${number}=                        Get Number Of Dropped Messages  ${logs_output}
    [Return]                          ${number}

RestartPmmapper
    [Arguments]                       ${envs}
    Remove Container                  ${CLIENT_CONTAINER_NAME}
    Sleep                             5s
    Run Pmmapper Container            ${DOCKER_CLIENT_IMAGE}      ${CLIENT_CONTAINER_NAME}        ${envs}        ${DR_NODE_IP}          ${NODE_IP}
    Sleep                             15s

SavePmMapperLogsAndDroppedCount
    [Arguments]                       ${test_name}                ${dropped_count}
    Run Process                      echo "Dropped: ${dropped_count}" > %{WORKSPACE}/archives/${test_name}_dropped_count.log  shell=yes
    Run Process                      docker logs ${CLIENT_CONTAINER_NAME} > %{WORKSPACE}/archives/${test_name}_pm_mapper_container_logs.log  shell=yes

