*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           PrhLibrary.py
Resource          ../../../common.robot

*** Keywords ***
Verify PNF ready sent
    [Arguments]    ${test_case_directory}
    ${pnf_entry}=    Get Data From File    ${test_case_directory}/aai-entry.json
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    ${expected_pnf_ready_event}=    Get Data From File    ${test_case_directory}/expected-pnf-ready-event.json
    Add PNF entry in AAI    ${pnf_entry}
    Set VES event in DMaaP    ${ves_event}
    Wait Until Keyword Succeeds    10x    3000ms    Check CBS ready
    Wait Until Keyword Succeeds    10x    3000ms    Check created PNF_READY notification    ${expected_pnf_ready_event}

Verify PNF ready sent and old logical link replaced in AAI
    [Arguments]    ${test_case_directory}
    ${logical_link}=   Get Data From File  ${test_case_directory}/logical-link.json
    ${expected_logical_link}=    Get Data From File  ${test_case_directory}/expected-logical-link.json
    Add logical link entry in AAI  ${logical_link}
    Verify PNF ready sent  ${test_case_directory}
    Wait Until Keyword Succeeds    10x    3000ms    Check created Logical Link    ${expected_logical_link}

Verify PNF ready sent and logical link created
    [Arguments]    ${test_case_directory}
    ${expected_logical_link}=    Get Data From File    ${test_case_directory}/expected-logical-link.json
    Verify PNF ready sent    ${test_case_directory}
    Check created Logical Link   ${expected_logical_link}

Verify event with missing required field is logged
    [Arguments]    ${test_case_directory}
    ${invalid_ves_event}=    Get Data From File    ${test_case_directory}/invalid-ves-event.json
    Set VES event in DMaaP    ${invalid_ves_event}
    Log    Invalid ves event: ${invalid_ves_event}
    ${notification}=    Create invalid notification    ${invalid_ves_event}
    ${error_msg}=    Set Variable    Incorrect json, consumerDmaapModel can not be created:
    Wait for PRH json log entry    20s    ${error_msg}    ${notification}

Verify incorrect JSON event is logged
    [Arguments]    ${test_case_directory}
    ${invalid_ves_event}=    Get Data From File    ${test_case_directory}/invalid-ves-event.json
    Set VES event in DMaaP    ${invalid_ves_event}
    Wait for PRH log entry    20s    java.lang.IllegalStateException: Not a JSON Object

Verify missing AAI record is logged
    [Arguments]    ${test_case_directory}
    ${incorrect_aai_entry}=    Get Data From File    ${test_case_directory}/incorrect-aai-entry.json
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Add PNF entry in AAI    ${incorrect_aai_entry}
    Set VES event in DMaaP    ${ves_event}
    Wait for PRH log entry    20s    Request failed for URL 'https://aai:3334/aai/v12/network/pnfs/pnf/NOK6061ZW8'. Response code: 404 Not Found

Verify AAI not responding is logged
    [Arguments]    ${test_case_directory}
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Ensure Container Is Exited    aai_simulator
    Set VES event in DMaaP    ${ves_event}
    Wait for one of PRH log entries    90s    connection timed out: aai    Host is unreachable: aai    No route to host: aai    failed to resolve 'aai'
    [Teardown]    Ensure Container Is Running   aai_simulator

Verify PNF re registration
    [Timeout]    500s
    [Arguments]    ${test_case_directory}
    ${aai_entry}=    Get Data From File    ${test_case_directory}/aai-entry.json
    Log    PNF Re-registration: AAI entry for AAI Simulator ${aai_entry}
    Add PNF entry in AAI    ${aai_entry}
    ${service_instance}=    Get Data From File    ${test_case_directory}/aai-entry-service-instance.json
    Add service instance entry in AAI    ${service_instance}
    ${logical_link}=    Get Data From File    ${test_case_directory}/logical-link.json
    Add logical link entry in AAI    ${logical_link}

    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Set VES event in DMaaP    ${ves_event}
    ${expected_pnf_update_event}=    Get Data From File    ${test_case_directory}/expected-pnf-update-event.json
    Wait Until Keyword Succeeds    10x    3000ms    Check created PNF_UPDATE notification    ${expected_pnf_update_event}
    Wait Until Keyword Succeeds    10x    3000ms    Check logical link not modified    ${test_case_directory}

Verify PNF ready sent when service instance non active
    [Arguments]    ${test_case_directory}
    ${pnf_entry}=    Get Data From File    ${test_case_directory}/aai-entry.json
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    ${expected_pnf_ready_event}=    Get Data From File    ${test_case_directory}/expected-pnf-ready-event.json
    ${service_instance}=    Get Data From File    ${test_case_directory}/aai-entry-service-instance.json
    Add PNF entry in AAI    ${pnf_entry}
    Add service instance entry in AAI    ${service_instance}

    Set VES event in DMaaP    ${ves_event}
    Wait Until Keyword Succeeds    10x    3000ms    Check CBS ready
    Wait Until Keyword Succeeds    10x    3000ms    Check created PNF_READY notification    ${expected_pnf_ready_event}

Check logical link not modified
    [Arguments]    ${test_case_directory}
    ${expected_logical_link}=    Get Data From File  ${test_case_directory}/logical-link.json
    ${existing_logical_link}=    Get Request    ${aai_session}    /verify/logical-link    headers=${suite_headers}
    Should Be Equal As JSON  ${expected_logical_link}    ${existing_logical_link.content}

Check CBS ready
    ${resp}=    Get Request    ${consul_session}    /v1/catalog/services
    Should Be Equal As Strings    ${resp.status_code}    200
    Log    Service Catalog response: ${resp.content}
    Dictionary Should Contain Key    ${resp.json()}    cbs    |Consul service catalog should contain CBS entry

Check created PNF_READY notification
    [Arguments]    ${expected_event_pnf_ready_in_dmaap}
    ${resp}=    Get Request    ${dmaap_session}    /verify/pnf_ready    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.content}    ${expected_event_pnf_ready_in_dmaap}

Check created PNF_UPDATE notification
    [Arguments]    ${expected_event_pnf_update_in_dmaap}
    ${resp}=    Get Request    ${dmaap_session}    /verify/pnf_update    headers=${suite_headers}
    Log    Response from DMaaP: ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.content}    ${expected_event_pnf_update_in_dmaap}

Check created Logical Link
    [Arguments]    ${expected_logical_link_in_aai}
    ${resp}=    Get Request    ${aai_session}    /verify/logical-link    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.content}    ${expected_logical_link_in_aai}

Wait for PRH log entry
    [Arguments]    ${timeout}    ${log_entry}
    Wait for one of PRH log entries    ${timeout}    ${log_entry}

Wait for one of PRH log entries
    [Arguments]    ${timeout}    @{log_entries}
    [Timeout]     ${timeout}
    ${found}=    Wait for one of docker log entries   prh   ${log_entries}
    Should Be True    ${found}

Wait for PRH json log entry
    [Arguments]    ${timeout}    ${prefix}    ${json}
    [Timeout]     ${timeout}
    ${found}=    Wait for log entry with json message    ${prefix}    ${json}
    Should Be True    ${found}

Create event parsing error
    [Arguments]    ${ves_event}
    ${notification}=    Create invalid notification    ${ves_event}
    ${error_msg}=    Catenate    SEPARATOR= \\n    |Incorrect json, consumerDmaapModel can not be created:     ${notification}
    [Return]    ${error_msg}

Add PNF entry in AAI
    [Arguments]    ${pnf_entry}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    ${resp}=    Put Request    ${aai_session}    /setup/add_pnf_entry    headers=${suite_headers}    data=${pnf_entry}
    Should Be Equal As Strings    ${resp.status_code}    200

Add service instance entry in AAI
    [Arguments]    ${aai_service_instance}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    ${resp}=    Put Request    ${aai_session}    /setup/add_service_instance    headers=${suite_headers}    data=${aai_service_instance}
    Should Be Equal As Strings    ${resp.status_code}    200

Add logical link entry in AAI
    [Arguments]  ${logical_link}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    ${resp}=    Put Request    ${aai_session}    /setup/add_logical_link    headers=${suite_headers}    data=${logical_link}
    Should Be Equal As Strings    ${resp.status_code}    200

Set VES event in DMaaP
    [Arguments]    ${ves_event}
    ${resp}=    Put Request    ${dmaap_session}    /setup/ves_event    headers=${suite_headers}    data=${ves_event}
    Should Be Equal As Strings    ${resp.status_code}    200

Should Be Equal As JSON
    [Arguments]    ${actual}    ${expected}
    Log    EXPECTED: ${expected}
    Log    ACTUAL: ${actual}
    ${expected_json}=    Evaluate    json.loads("""${expected}""")    json
    ${actual_json}=    Evaluate    json.loads("""${actual}""")    json
    Should Be Equal    ${actual_json}    ${expected_json}

Reset Simulators
    Reset AAI simulator
    Reset DMaaP simulator

Reset AAI simulator
    ${resp}=    Post Request     ${aai_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200


Verify change logging level
    ${logger}=    Set Variable    org.onap.dcaegen2.services.prh.controllers.AppInfoController
    Change logging level    ${logger}    TRACE
    Verify logging level    ${logger}    TRACE
    Verify logs with heartbeat
    [Teardown]    Change logging level    ${logger}    INFO

Change logging level
    [Arguments]    ${logger}    ${log_level}
    ${request_body}=    Create Dictionary    configuredLevel=${log_level}
    ${resp}=    Post Request    prh_session    /actuator/loggers/${logger}    json=${request_body}
    Should Be Equal As Integers    ${resp.status_code}    204

Verify logging level
    [Arguments]    ${logger}    ${expected_log_level}
    ${resp}=    Get Request    prh_session  /actuator/loggers/${logger}
    Should Be Equal As Integers    ${resp.status_code}    200
    Log    ${resp.content}
    Should Be Equal As Strings   ${resp.json()["configuredLevel"]}    ${expected_log_level}    ignore_case=true

Verify logs with heartbeat
    Get Request    prh_session    /heartbeat
    Verify PRH logs contains    Heartbeat request received

Verify PRH logs contains
   [Arguments]    ${expected_entry}
   ${log}=    Get docker logs since test start    prh
   Should Contain    ${log}    ${expected_entry}
