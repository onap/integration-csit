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
    #Wait Until Keyword Succeeds    100x    100ms    Check PRH log docker

Invalid event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${invalid_notification}=    create ves notification    ${data}
    ${notification}=    Catenate    SEPARATOR= \\n    |Incorrect json, consumerDmaapModel can not be created:     ${invalid_notification}
    Wait Until Keyword Succeeds    100x    100ms    Check PRH log    ${notification}

Valid event processing
    [Arguments]    ${input_valid__ves_event_in_dmaap}    ${input_aai_entries}
    [Timeout]    30s
    ${data_ves}=    Get Data From File    ${input_valid__ves_event_in_dmaap}
    ${data_aai}=    Get Data From File    ${input_aai_entries}
    ${pnf_name}=    Create PNF name    ${data_ves}
    Set PNF name in AAI    ${pnf_name}
    Set PNF content in AAI    ${data_aai}
    Set event in DMaaP    ${data_ves}
    ${expected_event_pnf_ready_in_dpaap}=    create pnf ready_notification as pnf ready    ${data_ves}
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
    [Arguments]    ${pnfs_name}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    Log    AAI setip is ${aai_setup_session}
    Log    Headers ${headers}
    Log    PNFS name ${pnfs_name}
    ${resp}=    Put Request    ${aai_setup_session}    /set_pnfs    headers=${headers}    data=${pnfs_name}
    Should Be Equal As Strings    ${resp.status_code}    200

Set PNF content in AAI
    [Arguments]    ${content}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    Log    AAI setip is ${aai_setup_session}
    Log    Headers ${headers}
    Log    PNFS content ${content}
    ${resp}=    Put Request    ${aai_setup_session}    /set_pnfs/content    headers=${headers}    data=${content}
    Should Be Equal As Strings    ${resp.status_code}    200

Set event in DMaaP
    [Arguments]    ${event_in_dmaap}
    ${resp}=    Put Request    ${dmaap_setup_session}    /set_get_event    headers=${suite_headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200

Reset AAI simulator
    #Show docker log aai
    ${resp}=    Post Request     ${aai_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

#Diagnostics
Check AAI log docker
    [Arguments]
    ${status}=   check for log aai
    Should Be Equal As Strings    ${status}    True

Check PRH log docker
    [Arguments]
    ${status}=   check for log prh
    Should Be Equal As Strings    ${status}    True