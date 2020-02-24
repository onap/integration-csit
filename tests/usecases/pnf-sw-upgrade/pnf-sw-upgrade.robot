*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDNC_KEYSTORE_CONFIG_PATH}    /config/netconf-keystore:keystore
${SDNC_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/pnf-simulator
${PNFSIM_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/pnf-simulator/yang-ext:mount/pnf-sw-upgrade:software-upgrade
${BP_UPLOAD_URL}    /api/v1/blueprint-model/publish
${BP_PROCESS_URL}    /api/v1/execution-service/process
${BP_ARCHIVE_PATH}    ${CURDIR}/data/blueprint_archive.zip
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48   


*** Test Cases ***
Test SDNC Keystore
      [Documentation]    Checking keystore after SDNC installation
      Create Session   sdnc  http://${REPO_IP}:8282/restconf
      &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
      ${resp}=    Get Request    sdnc    ${SDNC_KEYSTORE_CONFIG_PATH}    headers=${headers}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${keystoreContent}=    Convert To String    ${resp.content}
      Log to console  *************************
      Log to console  ${resp.content}
      Log to console  *************************

Test BP-PROC upload blueprint archive
     [Documentation]    Upload Blueprint archive to BP processor
     Create Session   blueprint  http://${REPO_IP}:8000
     ${bp_archive}=    Get Binary File    ${BP_ARCHIVE_PATH}
     &{bp_file}=    create Dictionary    file    ${bp_archive} 
     &{headers}=  Create Dictionary    Authorization=Basic Y2NzZGthcHBzOmNjc2RrYXBwcw==
     ${resp}=    Post Request    blueprint    ${BP_UPLOAD_URL}    files=${bp_file}    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}    200

Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'

Get pnf workflow
    Create Session   api_handler_session  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${get_pnfworkflows_request}=    Get Request    api_handler_session    /onap/so/infra/workflowSpecifications/v1/pnfWorkflows     headers=${headers}
    Run Keyword If  '${get_pnfworkflows_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${get_pnfworkflows_request.content}
    ${pnfworkflows_json_response}=    Evaluate     json.loads(r"""${get_pnfworkflows_request.content}""", strict=False)    json
    ${workflow_uuid}=          Set Variable         ${pnfworkflows_json_response}[workflowSpecificationList][workflowSpecification][artifactInfo][artifactUuid]
    ${workflow_name}=          Set Variable         ${pnfworkflows_json_response}[workflowSpecificationList][workflowSpecification][artifactInfo][artifactName]
    SET GLOBAL VARIABLE       ${workflow_uuid}
    Run Keyword If  '${actual_request_state}' == 'PNFSoftwareUpgrade.bpmn'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${workflow_name}'    'PNFSoftwareUpgrade.bpmn'


Invoke Service Instantiation
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceInstantiationRequest.json
    ${pnfName}=    Set Variable    "PNFDemo"
    ${serviceInstanceId}=    Set Variable    "cd4decf6-4f27-4775-9561-0e683ed43635"
    SET GLOBAL VARIABLE       ${pnfName}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/instanceManagement/v1/serviceInstances/${serviceInstanceId}/pnfs/${pnfName}/workflows/${workflow_uuid}    data=${data}    headers=${headers}
    Run Keyword If  '${service_instantiation_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${service_instantiation_request.content}
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${service_instance_Id}=     Set Variable       ${service_instantiation_json_response}[requestReferences][instanceId]
    SET GLOBAL VARIABLE       ${service_instance_Id}
    ${actual_request_state}=    Set Variable    ""

    : FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
    \   ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
    \   Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
    \   log to console      ${orchestration_status_request.content}
    \   ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
    \   ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
    \   Log To Console    Received actual repsonse status:${actual_request_state}
    \   RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
    \   log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
    \   SLEEP   ${SLEEP_INTERVAL_SEC}s

    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'
    
Test PNF Configuration update
     [Documentation]    Checking PNF configuration params
     Create Session   sdnc  http://${REPO_IP}:8282/restconf
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount.xml
     Log to console  ${mount}
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
     ${resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}    201
     Sleep  10
     &{headers1}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
     ${resp1}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers1}
     Should Be Equal As Strings    ${resp1.status_code}    200
     Log to console  ${resp1.content}
     Should Contain  ${resp1.text}     ""

Test AAI-update for target software version
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json    verify=False
    : FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
    \   ${get_pnf_request}=    Get Request    aai_simulator_session    aai/v11/network/pnfs/pnf/${pnfName}     headers=${headers}
    \   Run Keyword If  '${get_pnf_request.status_code}' == '200'  log to console   \nexecuted with expected result
    \   ${get_pnf_json_response}=    Evaluate     json.loads(r"""${get_pnf_request.content}""", strict=False)    json
    \   ${sw_version}=          Set Variable         ${get_pnf_json_response}[sw-version]
    \   Run Keyword If  '${sw_version}' == 'sfv2.0.0'  log to console      Exit For Loop
    \   log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
    \   SLEEP   ${SLEEP_INTERVAL_SEC}s

    Log To Console     final target software version received: ${sw_version}
    Run Keyword If  '${sw_version}' == 'sfv2.0.0'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${sw_version}'    'sfv2.0.0'
