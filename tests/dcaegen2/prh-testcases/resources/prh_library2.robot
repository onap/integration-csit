*** Settings ***
Library           RequestsLibrary
Library           Collections
Resource          ../../../common.robot

*** Keywords ***
VES event with additional fields
    [Arguments]    ${test_case_directory}
    ${pnf_entry}=    Get Data From File    ${test_case_directory}/aai-entry.json
    ${ves_event}=    Get Data From File    ${test_case_directory}/ves-event.json
    ${expected_pnf_ready_event}=    Get Data From File    ${test_case_directory}/expected-pnf-ready-event.json
    ${expected_logical_link}=    Get Data From File    ${test_case_directory}/expected-logical-link.json
    Add PNF entry in AAI    ${pnf_entry}
    Set VES event in DMaaP    ${ves_event}
    Wait Until Keyword Succeeds    50x    100ms    Check recorded PNF_READY notification    ${expected_pnf_ready_event}
    Check recorded Logical Link    ${expected_logical_link}

Check recorded PNF_READY notification
    [Arguments]    ${expected_event_pnf_ready_in_dpaap}
    ${resp}=    Get Request    ${dmaap_setup_session}    /setup/pnf_ready    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.text}    ${expected_event_pnf_ready_in_dpaap}

Check recorded Logical Link
    [Arguments]    ${expected_logical_link_in_aai}
    ${resp}=    Get Request    ${aai_setup_session}    /setup/created_logical_link    headers=${suite_headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As JSON    ${resp.text}    ${expected_logical_link_in_aai}

Add PNF entry in AAI
    [Arguments]    ${pnf_entry}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    Log    PNF entry ${pnf_entry}
    ${resp}=    Put Request    ${aai_setup_session}    /add_pnf_entry    headers=${suite_headers}    data=${pnf_entry}
    Should Be Equal As Strings    ${resp.status_code}    200

Set VES event in DMaaP
    [Arguments]    ${ves_event}
    ${resp}=    Put Request    ${dmaap_setup_session}    /set_get_event    headers=${suite_headers}    data=${ves_event}
    Log    DMaaP url ${DMAAP_SIMULATOR_SETUP_URL}
    Log    PNF entry ${ves_event}
    Should Be Equal As Strings    ${resp.status_code}    200

Create sessions
    Create Session    dmaap_setup_session    ${DMAAP_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${dmaap_setup_session}    dmaap_setup_session
    Create Session    aai_setup_session    ${AAI_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${aai_setup_session}    aai_setup_session

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

Should Be Equal As JSON
    [Arguments]    ${first_string}    ${second_string}
    ${first_dictionary}=    String To Dictionary    ${first_string}
    ${second_dictionary}=    String To Dictionary    ${second_string}
    Dictionaries Should Be Equal    ${first_dictionary}    ${second_dictionary}

String To Dictionary
    [Arguments]    ${json_string}
    ${dictionary}=    Evaluate    json.loads('''${json_string}''')    json
    [Return]    ${dictionary}
