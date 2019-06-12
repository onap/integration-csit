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

Verify PNF ready sent and logical link created
    [Arguments]    ${test_case_directory}
    ${expected_logical_link}=    Get Data From File    ${test_case_directory}/expected-logical-link.json
    Verify PNF ready sent    ${test_case_directory}
    Check created Logical Link   ${expected_logical_link}

Verify event with missing required field is logged
    [Arguments]    ${test_case_directory}
    ${invalid_ves_event}=    Get Data From File    ${test_case_directory}/invalid-ves-event.json
    Set VES event in DMaaP    ${invalid_ves_event}
    ${notification}=    Create invalid notification    ${invalid_ves_event}
    ${error_msg}=    Set Variable    Incorrect json, consumerDmaapModel can not be created:
    Wait Until Keyword Succeeds    10x    3000ms    Check PRH json log    ${error_msg}    ${notification}

Verify incorrect JSON event is logged
    [Timeout]    60s
    [Arguments]    ${test_case_directory}
    ${invalid_ves_event}=    Get Data From File    ${test_case_directory}/invalid-ves-event.json
    Set VES event in DMaaP    ${invalid_ves_event}
    Check PRH log    |com.google.gson.JsonSyntaxException: Expected a com.google.gson.JsonArray

Verify missing AAI record is logged
    [Timeout]    100s
    [Arguments]    ${test_case_directory}
    ${incorrect_aai_entry}=    Get Data From File    ${test_case_directory}/incorrect-aai-entry.json
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Add PNF entry in AAI    ${incorrect_aai_entry}
    Set VES event in DMaaP    ${ves_event}
    Check PRH log    Request failed for URL 'https://aai:3334/aai/v12/network/pnfs/pnf/NOK6061ZW8'. Response code: 404 Not Found

Verify AAI not responding is logged
    [Timeout]    100s
    [Arguments]    ${test_case_directory}
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Ensure Container Is Exited    aai_simulator
    Set VES event in DMaaP    ${ves_event}
    Check PRH log    connection timed out: aai    Host is unreachable: aai
    Ensure Container Is Running   aai_simulator

Verify PNF re registration
    [Timeout]    100s
    [Arguments]    ${test_case_directory}
    ${expected_logical_link}=    Get Data From File    ${test_case_directory}/expected-logical-link.json
    Verify PNF ready sent    ${test_case_directory}
    Check created Logical Link    ${expected_logical_link}

    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    Set VES event in DMaaP    ${ves_event}
    ${expected_pnf_update_event}=    Get Data From File    ${test_case_directory}/expected-pnf-update-event.json
    Wait Until Keyword Succeeds    10x    3000ms    Check created PNF_UPDATE notification    ${expected_pnf_update_event}

Check CBS ready
    ${resp}=    Get Request    ${consul_setup_session}    /v1/catalog/services
    Should Be Equal As Strings    ${resp.status_code}    200
    Log    Service Catalog response: ${resp.content}
    Dictionary Should Contain Key    ${resp.json()}    cbs    |Consul service catalog should contain CBS entry

Check created PNF_READY notification
    [Arguments]    ${expected_event_pnf_ready_in_dpaap}
    ${resp}=    Get Request    ${dmaap_setup_session}    /verify/pnf_ready    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.content}    ${expected_event_pnf_ready_in_dpaap}

Check created PNF_UPDATE notification
    [Arguments]    ${expected_event_pnf_update_in_dpaap}
    ${resp}=    Get Request    ${dmaap_setup_session}    /verify/pnf_update    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    #Should Be Equal As JSON    ${resp.content}    ${expected_event_pnf_ready_in_dpaap}

Check created Logical Link
    [Arguments]    ${expected_logical_link_in_aai}
    ${resp}=    Get Request    ${aai_setup_session}    /verify/created_logical_link    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.content}    ${expected_logical_link_in_aai}

Check PRH log
    [Arguments]    @{log_entries}
    ${found}=    Find one of log entryies    ${log_entries}
    Should Be True    ${found}

Check PRH json log
    [Arguments]    ${prefix}    ${json}
    ${found}=    Find log json    ${prefix}    ${json}
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
    ${resp}=    Put Request    ${aai_setup_session}    /setup/add_pnf_entry    headers=${suite_headers}    data=${pnf_entry}
    Should Be Equal As Strings    ${resp.status_code}    200

Set VES event in DMaaP
    [Arguments]    ${ves_event}
    ${resp}=    Put Request    ${dmaap_setup_session}    /setup/ves_event    headers=${suite_headers}    data=${ves_event}
    Should Be Equal As Strings    ${resp.status_code}    200

Should Be Equal As JSON
    [Arguments]    ${actual}    ${expected}
    Log    EXPECTED: ${expected}
    Log    ACTUAL: ${actual}
    ${expected_json}=    Evaluate    json.loads("""${expected}""")    json
    ${actual_json}=    Evaluate    json.loads("""${actual}""")    json
    Should Be Equal    ${actual_json}    ${expected_json}

Create sessions
    Create Session    dmaap_setup_session    ${DMAAP_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${dmaap_setup_session}    dmaap_setup_session
    Create Session    aai_setup_session    ${AAI_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${aai_setup_session}    aai_setup_session
    Create Session    consul_setup_session    ${CONSUL_SETUP_URL}
    Set Suite Variable    ${consul_setup_session}    consul_setup_session

Reset Simulators
    Reset AAI simulator
    Reset DMaaP simulator

Reset AAI simulator
    ${resp}=    Post Request     ${aai_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Create headers
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}