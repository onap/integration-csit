*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDNC_KEYSTORE_CONFIG_PATH}    /restconf/config/netconf-keystore:keystore
${SDNC_MOUNT_PATH}    /restconf/config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
${SDNC_MOUNT_PATH2}    /restconf/config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo1
${PNFSIM_MOUNT_PATH}    /restconf/config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo/yang-ext:mount/pnf-sw-upgrade:software-upgrade
${PNFSIM_MOUNT_PATH2}    /restconf/config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo1/yang-ext:mount/pnf-sw-upgrade:software-upgrade
${PNFSIM_DELETE_PATH}    /restconf/config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
${BP_UPLOAD_URL}    /api/v1/blueprint-model/publish
${BP_PROCESS_URL}    /api/v1/execution-service/process
${BP_ARCHIVE_PATH}    ${CURDIR}/data/blueprint_archive.zip
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     20   


*** Test Cases ***
Test SDNC Keystore
    [Documentation]    Checking keystore after SDNC installation
    Create Session   sdnc  http://${REPO_IP}:8282
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
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/app/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'
    ${serviceInstanceId}=    Set Variable    cd4decf6-4f27-4775-9561-0e683ed43635
    SET GLOBAL VARIABLE     ${serviceInstanceId}
    ${pnfName}=    Set Variable    PNFDemo
    SET GLOBAL VARIABLE      ${pnfName}
    ${pnfName1}=    Set Variable    PNFDemo1
    SET GLOBAL VARIABLE      ${pnfName1}

Get pnf workflow
    Create Session   api_handler_session  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${get_pnfworkflows_request}=    Get Request    api_handler_session    /onap/so/infra/workflowSpecifications/v1/workflows     headers=${headers}
    Run Keyword If  '${get_pnfworkflows_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${get_pnfworkflows_request.content}
    ${pnfworkflows_json_response}=    Evaluate     json.loads(r"""${get_pnfworkflows_request.content}""", strict=False)    json
    ${all_wf_members}=    Set Variable     ${pnfworkflows_json_response['workflowSpecificationList']}
    ${activate_workflow_uuid}=    Set Variable    ""
    ${activate_workflow_name}=    Set Variable    ""
    ${download_workflow_uuid}=    Set Variable    ""
    ${download_workflow_name}=    Set Variable    ""
    ${serviceLevel_workflow_uuid}=    Set Variable    ""
    ${serviceLevel_workflow_name}=    Set Variable    ""
    FOR    ${member}     IN      @{all_wf_members}
       ${workflow_uuid}=          Set Variable        ${member}[workflowSpecification][artifactInfo][artifactUuid]
       ${workflow_name}=          Set Variable        ${member}[workflowSpecification][artifactInfo][artifactName]
       Log to console   The workflow ${workflow_name} has uuid : ${workflow_uuid}
       ${activate_workflow_uuid}=    Set Variable If  '${workflow_name}' == 'GenericPnfSoftwareUpgrade'    ${workflow_uuid}   ${activate_workflow_uuid}
       ${activate_workflow_name}=    Set Variable If  '${workflow_name}' == 'GenericPnfSoftwareUpgrade'    ${workflow_name}   ${activate_workflow_name}
       ${download_workflow_uuid}=    Set Variable If  '${workflow_name}' == 'GenericPnfSWUPDownload'       ${workflow_uuid}   ${download_workflow_uuid}
       ${download_workflow_name}=    Set Variable If  '${workflow_name}' == 'GenericPnfSWUPDownload'       ${workflow_name}   ${download_workflow_name}
       ${serviceLevel_workflow_uuid}=    Set Variable If  '${workflow_name}' == 'ServiceLevelUpgrade'      ${workflow_uuid}   ${serviceLevel_workflow_uuid}
       ${serviceLevel_workflow_name}=    Set Variable If  '${workflow_name}' == 'ServiceLevelUpgrade'      ${workflow_name}   ${serviceLevel_workflow_name}
    END

    SET GLOBAL VARIABLE       ${activate_workflow_uuid}
    SET GLOBAL VARIABLE       ${download_workflow_uuid}
    SET GLOBAL VARIABLE       ${serviceLevel_workflow_uuid}
    Run Keyword If  '${activate_workflow_name}' == 'GenericPnfSoftwareUpgrade'  log to console   \nexecuted with expected result
    Run Keyword If  '${download_workflow_name}' == 'GenericPnfSWUPDownload'  log to console   \nexecuted with expected result
    Run Keyword If  '${serviceLevel_workflow_name}' == 'ServiceLevelUpgrade'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${activate_workflow_name}'    'GenericPnfSoftwareUpgrade'
    Should Be Equal As Strings    '${download_workflow_name}'    'GenericPnfSWUPDownload'
    Should Be Equal As Strings    '${serviceLevel_workflow_name}'    'ServiceLevelUpgrade'

Invoke Service Instantiation for pnf software download
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceInstantiationDownloadRequest.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json    X-ONAP-RequestID=0ddc448d-5513-44bc-8b02-5759d84600d5    X-ONAP-PartnerName=ONAP    X-RequestorID=VID
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/instanceManagement/v1/serviceInstances/${serviceInstanceId}/pnfs/${pnfName}/workflows/${download_workflow_uuid}    data=${data}    headers=${headers}
    Run Keyword If  '${service_instantiation_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${service_instantiation_request.content}
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""
     FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       Log To Console    Received actual repsonse status:${actual_request_state}
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
     END
    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

Test verify PNF Configuration for software download
     [Documentation]    Checking PNF configuration params
     Create Session   sdnc  http://${REPO_IP}:8282
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount.json
     Log to console  ${mount}
     ${pnf_mount_resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${pnf_mount_resp.status_code}    201
     SLEEP   10
     ${pnfsim_software_resp}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers}
     Should Be Equal As Strings    ${pnfsim_software_resp.status_code}    200
     Log to console  ${pnfsim_software_resp.content}
     ${pnfsim_software_resp_json}=    Evaluate     json.loads(r"""${pnfsim_software_resp.content}""", strict=False)    json
     ${all_upgp_members}=    Set Variable     ${pnfsim_software_resp_json['software-upgrade']['upgrade-package']}
     FOR    ${member}     IN      @{all_upgp_members}
        ${soft_ver}=    Get From Dictionary   ${member}     software-version
        ${soft_status}=    Get From Dictionary   ${member}     current-status
        Log to console   The node ${pnfName} has software version ${soft_ver} : ${soft_status}
        Run Keyword If  '${soft_ver}' == 'pnf_sw_version-2.0.0'   Exit For Loop
     END
     Run Keyword If  '${soft_ver}' == 'pnf_sw_version-2.0.0'  log to console   \nexecuted with expected result
     Should Be Equal As Strings    '${soft_ver}'    'pnf_sw_version-2.0.0'
     Should Be Equal As Strings    '${soft_status}'    'DOWNLOAD_COMPLETED'

Invoke Service Instantiation for pnf software activation
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceInstantiationActivationRequest.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json    X-ONAP-RequestID=4e104e12-5539-4557-b31e-00369398c214    X-ONAP-PartnerName=ONAP    X-RequestorID=VID
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/instanceManagement/v1/serviceInstances/${serviceInstanceId}/pnfs/${pnfName}/workflows/${activate_workflow_uuid}    data=${data}    headers=${headers}
    Run Keyword If  '${service_instantiation_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${service_instantiation_request.content}
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${actual_request_state}=    Set Variable    ""
     FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${orchestration_status_request.content}
       ${orchestration_json_response}=    Evaluate     json.loads(r"""${orchestration_status_request.content}""", strict=False)    json
       ${actual_request_state}=     SET VARIABLE       ${orchestration_json_response}[request][requestStatus][requestState]
       Log To Console    Received actual repsonse status:${actual_request_state}
       RUN KEYWORD IF   '${actual_request_state}' == 'COMPLETE' or '${actual_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
     END
    Log To Console     final repsonse status received: ${actual_request_state}
    Run Keyword If  '${actual_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_request_state}'    'COMPLETE'

Test verify PNF Configuration for software activate
     [Documentation]    Checking PNF configuration params
     Create Session   sdnc  http://${REPO_IP}:8282
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount.json
     Log to console  ${mount}
     ${pnf_mount_resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${pnf_mount_resp.status_code}    201
     SLEEP   10
     ${pnfsim_software_resp}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers}
     Should Be Equal As Strings    ${pnfsim_software_resp.status_code}    200
     Log to console  ${pnfsim_software_resp.content}
     ${pnfsim_software_resp_json}=    Evaluate     json.loads(r"""${pnfsim_software_resp.content}""", strict=False)    json
     ${all_upgp_members}=    Set Variable     ${pnfsim_software_resp_json['software-upgrade']['upgrade-package']}
     FOR    ${member}     IN      @{all_upgp_members}
        ${soft_ver}=    Get From Dictionary   ${member}     software-version
        ${soft_status}=    Get From Dictionary   ${member}     current-status
        Log to console   The node ${pnfName} has software version ${soft_ver} : ${soft_status}
        Run Keyword If  '${soft_ver}' == 'pnf_sw_version-3.0.0'   Exit For Loop
     END
     Run Keyword If  '${soft_ver}' == 'pnf_sw_version-3.0.0'  log to console   \nexecuted with expected result
     Should Be Equal As Strings    '${soft_ver}'    'pnf_sw_version-3.0.0'
     Should Be Equal As Strings    '${soft_status}'    'ACTIVATION_COMPLETED'

Test AAI-update for target software version verify
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Authorization=Basic YWFpOmFhaS5vbmFwLm9yZzpkZW1vMTIzNDU2IQ==    Content-Type=application/json    Accept=application/json    verify=False
    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${get_pnf_request}=    Get Request    aai_simulator_session    aai/v11/network/pnfs/pnf/${pnfName}     headers=${headers}
       Run Keyword If  '${get_pnf_request.status_code}' == '200'  log to console   \nexecuted with expected result
       ${get_pnf_json_response}=    Evaluate     json.loads(r"""${get_pnf_request.content}""", strict=False)    json
       Log to console  ${get_pnf_json_response}
       ${sw_version}=          Set Variable         ${get_pnf_json_response}[sw-version]
       Log to console  ${sw_version}
       Run Keyword If  '${sw_version}' == 'pnf_sw_version-3.0.0'   Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END
    Log To Console     final target software version received: ${sw_version}
    Run Keyword If  '${sw_version}' == 'pnf_sw_version-3.0.0'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${sw_version}'    'pnf_sw_version-3.0.0'

Distribute ServiceLevel Upgrade Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate_2.0.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/app/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'
    ${serviceInstanceId}=    Set Variable    8351245d-50da-4695-8756-3a22618377f7
    SET GLOBAL VARIABLE     ${serviceInstanceId}

Get Service-Model-Version From AAI Using Service-Model-InVariant-UUId
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Authorization=Basic YWFpOmFhaS5vbmFwLm9yZzpkZW1vMTIzNDU2IQ==    Content-Type=application/xml    Accept=application/xml    verify=False
    ${model-invariant-id}=    Set Variable    a51e2bef-961c-496f-b235-b4540400e885
    ${get_serviceVersion}=    Get Request    aai_simulator_session    aai/v11/service-design-and-creation/models/model/${model-invariant-id}/model-vers     headers=${headers}
    Run Keyword If  '${get_serviceVersion.status_code}' == '200'  log to console   \nExecuted with expected
    Log to console  ${get_serviceVersion.content}
    Should Be Equal As Strings    ${get_serviceVersion.status_code}    200
    ${serviceVersion_json_response}=    Evaluate    json.loads(r"""${get_serviceVersion.content}""", strict=False)    json
    ${all_service_version}=    Set Variable    ${serviceVersion_json_response['model-vers']['model-ver']}
    ${model-version-id_1}=    Set Variable    ""
    ${model-version-id_2}=    Set Variable    ""
    FOR    ${member}    IN    @{all_service_version}
       ${model-version}=    Set Variable    ${member}[model-version]
       ${model-version-id}=    Set Variable    ${member}[model-version-id]
       Log to console    The ServiceModel Version ${model-version} has ModelVersion Id : ${model-version-id}
       ${model-version-id_1}=    Set Variable If  '${model-version}' == '1.0'    ${model-version-id}   ${model-version-id_1}
       ${model-version-id_2}=    Set Variable If  '${model-version}' == '2.0'    ${model-version-id}   ${model-version-id_2}
    END
    SET GLOBAL VARIABLE    ${model-version-id_1}
    SET GLOBAL VARIABLE    ${model-version-id_2}

Invoke Service Instantiation for ServiceLevel Upgrade
    Create Session   api_handler_session  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}serviceLevelUpgradeRequest.json
    ${serviceInstanceId}=    Set Variable    ${model-version-id_1}
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json    X-ONAP-RequestID=0ffc559c-5513-44bc-8b02-5759d84600f4    X-ONAP-PartnerName=ONAP    X-RequestorID=VID
    ${service_instantiation_request}=    Post Request    api_handler_session    /onap/so/infra/instanceManagement/v1/serviceInstances/${serviceInstanceId}/workflows/${serviceLevel_workflow_uuid}    data=${data}    headers=${headers}
    Run Keyword If  '${service_instantiation_request.status_code}' == '200'  log to console   \nexecuted with expected result
    log to console      ${service_instantiation_request.content}
    ${service_instantiation_json_response}=    Evaluate     json.loads(r"""${service_instantiation_request.content}""", strict=False)    json
    ${request_ID}=          Set Variable         ${service_instantiation_json_response}[requestReferences][requestId]
    ${actual_service_request_state}=    Set Variable    ""
     FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${orchestration_status_service_request}=   Get Request  api_handler_session   /onap/so/infra/orchestrationRequests/v7/${request_ID}
       Run Keyword If  '${orchestration_status_service_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${orchestration_status_service_request.content}
       ${orchestration_json_service_response}=    Evaluate     json.loads(r"""${orchestration_status_service_request.content}""", strict=False)    json
       ${actual_service_request_state}=     SET VARIABLE       ${orchestration_json_service_response}[request][requestStatus][requestState]
       Log To Console    Received actual repsonse status:${actual_service_request_state}
       RUN KEYWORD IF   '${actual_service_request_state}' == 'COMPLETE' or '${actual_service_request_state}' == 'FAILED'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
     END
    Log To Console     final repsonse status received: ${actual_service_request_state}
    Run Keyword If  '${actual_service_request_state}' == 'COMPLETE'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_service_request_state}'    'COMPLETE'

Test Verify PNF-1 Configuration for Service Level Upgrade
     [Documentation]    Checking PNF configuration params
     Create Session   sdnc  http://${REPO_IP}:8282
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount.json
     Log to console  ${mount}
     ${pnf_mount_resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${pnf_mount_resp.status_code}    201
     SLEEP   10
     ${pnfsim_software_resp}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers}
     Should Be Equal As Strings    ${pnfsim_software_resp.status_code}    200
     Log to console  ${pnfsim_software_resp.content}
     ${pnfsim_software_resp_json}=    Evaluate     json.loads(r"""${pnfsim_software_resp.content}""", strict=False)    json
     ${all_upgp_members}=    Set Variable     ${pnfsim_software_resp_json['software-upgrade']['upgrade-package']}
     FOR    ${member}     IN      @{all_upgp_members}
        ${soft_ver}=    Get From Dictionary   ${member}     software-version
        ${soft_status}=    Get From Dictionary   ${member}     current-status
        Log to console   The node ${pnfName} has software version ${soft_ver} : ${soft_status}
        Run Keyword If  '${soft_ver}' == 'pnf_sw_version-4.0.0'   Exit For Loop
     END
     Run Keyword If  '${soft_ver}' == 'pnf_sw_version-4.0.0'  log to console   \nexecuted with expected result
     Should Be Equal As Strings    '${soft_ver}'    'pnf_sw_version-4.0.0'
     Should Be Equal As Strings    '${soft_status}'    'ACTIVATION_COMPLETED'

Test AAI-Update for PNF-1 Target Software Version after Service Level Upgrade
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Authorization=Basic YWFpOmFhaS5vbmFwLm9yZzpkZW1vMTIzNDU2IQ==    Content-Type=application/json    Accept=application/json    verify=False
    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${get_pnf_request}=    Get Request    aai_simulator_session    aai/v11/network/pnfs/pnf/${pnfName}     headers=${headers}
       Run Keyword If  '${get_pnf_request.status_code}' == '200'  log to console   \nexecuted with expected result
       ${get_pnf_json_response}=    Evaluate     json.loads(r"""${get_pnf_request.content}""", strict=False)    json
       Log to console  ${get_pnf_json_response}
       ${sw_version}=          Set Variable         ${get_pnf_json_response}[sw-version]
       Log to console  ${sw_version}
       Run Keyword If  '${sw_version}' == 'pnf_sw_version-4.0.0'   Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END
    Log To Console     final target software version received: ${sw_version}
    Run Keyword If  '${sw_version}' == 'pnf_sw_version-4.0.0'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${sw_version}'    'pnf_sw_version-4.0.0'

Test Verify PNF-2 Configuration for Service Level Upgrade
     [Documentation]    Checking PNF configuration params
     Create Session   sdnc  http://${REPO_IP}:8282
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount2.json
     Log to console  ${mount}
     ${pnf_mount_resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH2}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${pnf_mount_resp.status_code}    201
     SLEEP   10
     ${pnfsim_software_resp}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH2}    headers=${headers}
     Should Be Equal As Strings    ${pnfsim_software_resp.status_code}    200
     Log to console  ${pnfsim_software_resp.content}
     ${pnfsim_software_resp_json}=    Evaluate     json.loads(r"""${pnfsim_software_resp.content}""", strict=False)    json
     ${all_upgp_members}=    Set Variable     ${pnfsim_software_resp_json['software-upgrade']['upgrade-package']}
     FOR    ${member}     IN      @{all_upgp_members}
        ${soft_ver}=    Get From Dictionary   ${member}     software-version
        ${soft_status}=    Get From Dictionary   ${member}     current-status
        Log to console   The node ${pnfName1} has software version ${soft_ver} : ${soft_status}
        Run Keyword If  '${soft_ver}' == 'pnf_sw_version-4.0.0'   Exit For Loop
     END
     Run Keyword If  '${soft_ver}' == 'pnf_sw_version-4.0.0'  log to console   \nexecuted with expected result
     Should Be Equal As Strings    '${soft_ver}'    'pnf_sw_version-4.0.0'
     Should Be Equal As Strings    '${soft_status}'    'ACTIVATION_COMPLETED'

Test AAI-Update for PNF-2 Target Software Version after Service Level Upgrade
    Create Session   aai_simulator_session  https://${REPO_IP}:9993
    &{headers}=  Create Dictionary    Authorization=Basic YWFpOmFhaS5vbmFwLm9yZzpkZW1vMTIzNDU2IQ==    Content-Type=application/json    Accept=application/json    verify=False
    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${get_pnf_request}=    Get Request    aai_simulator_session    aai/v11/network/pnfs/pnf/${pnfName1}     headers=${headers}
       Run Keyword If  '${get_pnf_request.status_code}' == '200'  log to console   \nexecuted with expected result
       ${get_pnf_json_response}=    Evaluate     json.loads(r"""${get_pnf_request.content}""", strict=False)    json
       Log to console  ${get_pnf_json_response}
       ${sw_version}=          Set Variable         ${get_pnf_json_response}[sw-version]
       Log to console  ${sw_version}
       Run Keyword If  '${sw_version}' == 'pnf_sw_version-4.0.0'   Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}s
    END
    Log To Console     final target software version received: ${sw_version}
    Run Keyword If  '${sw_version}' == 'pnf_sw_version-4.0.0'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${sw_version}'    'pnf_sw_version-4.0.0'