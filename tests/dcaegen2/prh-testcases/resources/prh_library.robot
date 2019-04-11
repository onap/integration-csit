*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           PrhLibrary.py
Resource          ../../../common.robot

*** Keywords ***
Create header
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Set Suite Variable    ${suite_headers}    ${headers}

Create sessions
    Create Session    dmaap_setup_session    ${DMAAP_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${dmaap_setup_session}    dmaap_setup_session
    Create Session    aai_setup_session    ${AAI_SIMULATOR_SETUP_URL}
    Set Suite Variable    ${aai_setup_session}    aai_setup_session

Reset Simulators
    Reset AAI simulator
    Reset DMaaP simulator

Invalid event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${invalid_notification}=    Create invalid notification    ${data}
    ${notification}=    Catenate    SEPARATOR= \\n    |Incorrect json, consumerDmaapModel can not be created:     ${invalid_notification}
    #TODO to fix after CBS merge
    #Wait Until Keyword Succeeds    100x    100ms    Check PRH log    ${notification}

Valid event processing
    [Arguments]    ${input_valid__ves_event_in_dmaap}    ${input_aai}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_valid__ves_event_in_dmaap}
    ${aai_entry_to_be_set}=    Get Data From File    ${input_aai}
    Set event in DMaaP    ${data}
    ${pnf_name}=    Create PNF name    ${data}
    Set PNF name in AAI    ${pnf_name}
    Set PNF content in AAI    ${aai_entry_to_be_set}
    ${expected_event_pnf_ready_in_dpaap}=    create pnf ready_notification as pnf ready    ${data}
    Wait Until Keyword Succeeds    100x    300ms    Check PNF_READY notification    ${expected_event_pnf_ready_in_dpaap}

Check PRH log
    [Arguments]    ${searched_log}
    ${status}=    Check for log    ${searched_log}
    Should Be Equal As Strings    ${status}    True

Check PNF_READY notification
    [Arguments]    ${expected_event_pnf_ready_in_dpaap}
    ${resp}=    Get Request    ${dmaap_setup_session}    /events/pnfReady    headers=${suite_headers}
    Should Be Equal    ${resp.text}    ${expected_event_pnf_ready_in_dpaap}

Set PNF name in AAI
    [Arguments]    ${pnf_name}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    Log    Http headers ${headers}
    Log    PNF name ${pnf_name}
    ${resp}=    Put Request    ${aai_setup_session}    /set_pnf    headers=${headers}    data=${pnf_name}
    Should Be Equal As Strings    ${resp.status_code}    200

Set PNF content in AAI
    [Arguments]    ${aai_pnf_content}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    Log    AAI url ${AAI_SIMULATOR_SETUP_URL}
    Log    Http headers ${headers}
    Log    PNF content ${aai_pnf_content}
    ${resp}=    Put Request    ${aai_setup_session}    /setup/add_pnf_entry    headers=${headers}    data=${aai_pnf_content}
    Should Be Equal As Strings    ${resp.status_code}    200

Set event in DMaaP
    [Arguments]    ${event_in_dmaap}
    ${resp}=    Put Request    ${dmaap_setup_session}    /set_get_event    headers=${suite_headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200

Reset AAI simulator
    ${resp}=    Post Request     ${aai_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200