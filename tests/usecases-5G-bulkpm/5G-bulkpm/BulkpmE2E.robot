*** Settings ***
Documentation	  Testing E2E VES,Dmaap,DFC,DR with File Ready event feed from xNF
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           Process
Resource          resources/bulkpm_keywords.robot
Library           resources/JsonValidatorLibrary.py
Library           resources/xNFLibrary.py


*** Variables ***
${VESC_URL}                              http://%{VESC_IP}:%{VESC_PORT}
${GLOBAL_APPLICATION_ID}                 robot-ves
${VES_ANY_EVENT_PATH}                    /eventListener/v7
${HEADER_STRING}                         content-type=application/json
${EVENT_DATA_FILE}                       %{WORKSPACE}/tests/usecases-5G-bulkpm/5G-bulkpm/assets/json_events/FileExistNotification.json

${TARGETURL_TOPICS}                      http://${DMAAP_MR_IP}:3904/topics
${TARGETURL_SUBSCR}                      http://${DMAAP_MR_IP}:3904/events/unauthenticated.VES_NOTIFICATION_OUTPUT/OpenDcae-c12/C12?timeout=1000
${CLI_EXEC_CLI}                          curl -k https://${DR_PROV_IP}:8443/internal/prov
${CLI_EXEC_CLI_FILECONSUMER}             docker exec fileconsumer-node /bin/sh -c "ls /opt/app/subscriber/delivery | grep .xml"
${CLI_EXEC_CLI_DFC_LOG}                  docker exec dcaegen2-datafile-collector /bin/sh -c "cat /var/log/ONAP/application.log" > %{WORKSPACE}/archives/dfc_docker.log
${CLI_EXEC_CLI_DFC_LOG_GREP}             grep "Datafile file published" %{WORKSPACE}/archives/dfc_docker.log
${CLI_EXEC_CLI_FILECONSUMER_CP}          docker cp fileconsumer-node:/opt/app/subscriber/delivery/A20181002.0000-1000-0015-1000_5G.xml.M %{WORKSPACE}
${CLI_EXEC_RENAME_METADATA}              mv %{WORKSPACE}/A20181002.0000-1000-0015-1000_5G.xml.M  %{WORKSPACE}/archives/metadata.json
${CLI_EXEC_CLI_PMMAPPER_LOG}             docker exec dcaegen2-pm-mapper /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log" > %{WORKSPACE}/archives/pmmapper_docker.log
${CLI_EXEC_CLI_PMMAPPER_LOG_GREP}        grep "XML validation successful" %{WORKSPACE}/archives/pmmapper_docker.log
${CLI_EXEC_CLI_PMMAPPER_LOG_GREP_VES}    grep "Successfully published VES events to messagerouter" %{WORKSPACE}/archives/pmmapper_docker.log
${metadataSchemaPath}                    %{WORKSPACE}/tests/usecases-5G-bulkpm/5G-bulkpm/assets/metadata.schema.json
${metadataJsonPath}                      %{WORKSPACE}/archives/metadata.json

*** Test Cases ***

Send VES File Ready Event to VES Collector
    [Tags]    Bulk_PM_E2E_01
    [Documentation]   Send VES File Ready Event
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Sleep     15s
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Sleep     5s
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Sleep     5s
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Sleep     5s
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202

Check VES Notification Topic is existing in Message Router
    [Tags]                          Bulk_PM_E2E_02
    [Documentation]                 Get the VES Notification topic on message router
    [Timeout]                       1 minute
    Sleep                           10s
    ${resp}=                        GetCall                         ${TARGETURL_TOPICS}
    log                             ${TARGETURL_TOPICS}
    log                             'JSON Response Code :'${resp}
    ${topics}=                      Evaluate                        $resp.json().get('topics')
    log                             ${topics}
    ${ListLength}=                  Get Length                      ${topics}
    log                             ${ListLength}
    List Should Contain Value       ${topics}                       unauthenticated.VES_NOTIFICATION_OUTPUT

Verify Data File Collector successfully publishes the PM XML file to the Data Router
    [Tags]                          Bulk_PM_E2E_03
    [Documentation]                 Check that DFC publishes the PM XML to the Data Router
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_DFC_LOG}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_DFC_LOG_GREP}    shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        Datafile file published


Verify Default Feed And File Consumer Subscription On Datarouter
    [Tags]                          Bulk_PM_E2E_04
    [Documentation]                 Verify Default Feed And File Consumer Subscription On Datarouter
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI}                     shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        https://dmaap-dr-prov/publish/1
    Should Contain                  ${cli_cmd_output.stdout}        http://datarouter-subscriber:7070


Verify Fileconsumer Receive PM file from Data Router
    [Tags]                          Bulk_PM_E2E_05
    [Documentation]                 Check  PM XML file exists on the File Consumer Simulator
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_FILECONSUMER}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        A20181002.0000-1000-0015-1000_5G.xml

Verify File Consumer Receive valid metadata from Data Router
    [Tags]                          Bulk_PM_E2E_06
    [Documentation]                 Check PM XML file is delivered to the FileConsumer Simulator with valid metadata
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_FILECONSUMER}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        A20181002.0000-1000-0015-1000_5G.xml.M
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_FILECONSUMER_CP}     shell=yes
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_RENAME_METADATA}         shell=yes
    ${validation_result}=           Validate                        ${metadataSchemaPath}    ${metadataJsonPath}
    Should Be Equal As Strings      ${validation_result}            0

Verify PM-Mapper successfully receives uncompressed the PM XML file
    [Tags]                          Bulk_PM_E2E_07
    [Documentation]                 Check that PM-Mapper receives the uncompressed PM XML file
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_PMMAPPER_LOG}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_PMMAPPER_LOG_GREP}    shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        XML validation successful

Verify PM-Mapper successfully publishes VES event the Message Router
    [Tags]                          Bulk_PM_E2E_08
    [Documentation]                 Check that PM-Mapper publishes VES onto the Message Router
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_PMMAPPER_LOG}    shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    ${cli_cmd_output}=              Run Process                     ${CLI_EXEC_CLI_PMMAPPER_LOG_GREP_VES}    shell=yes
    Should Contain                  ${cli_cmd_output.stdout}        Successfully published VES events to messagerouter