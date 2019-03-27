*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           BbsLibrary.py
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

Set AAI Records
    [Timeout]    30s
    ${data}=    Get Data From File    ${AAI_PNFS}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp} =    Put Request    ${aai_setup_session}    /set_pnfs    headers=${headers}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${data}=    Get Data From File    ${AAI_SERVICES}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp} =    Put Request    ${aai_setup_session}    /set_services    headers=${headers}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${data}=    Get Data From File    ${AAI_PNF_NOT_FOUND}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp} =    Put Request    ${aai_setup_session}    /set_pnf_not_found    headers=${headers}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}    200

Invalid rgmac auth event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${err_msg}=    Catenate    SEPARATOR= \\n    RGW MAC address taken from event (Optional[]) does not match with A&AI metadata corresponding value
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    ${err_msg}

Invalid auth event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${json_obj}=    Get invalid auth elements    ${data}
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    Incorrect CPE Authentication JSON event:
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    ${json_obj}
Valid auth event processing
    [Arguments]    ${input_valid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_valid_event_in_dmaap}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    20x    2000ms    Check policy    ${AUTH_POLICY}

Check policy
    [Arguments]    ${json_policy_file}
    ${resp}=    Get Request    ${dmaap_setup_session}    /events/dcaeClOutput   headers=${suite_headers}
    ${data}=    Get Data From File    ${json_policy_file}
    ${result}=    Compare policy    ${resp.text}    ${data}
    Should Be Equal As Strings    ${result}    True

Invalid update event processing
    [Arguments]    ${input_invalid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_invalid_event_in_dmaap}
    Set event in DMaaP    ${data}
    ${json_obj}=    Get invalid update elements    ${data}
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    Incorrect Re-Registration
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    JSON event:
    Wait Until Keyword Succeeds    20x    2000ms    Check BBS log    ${json_obj}


Valid update event processing
    [Arguments]    ${input_valid_event_in_dmaap}
    [Timeout]    30s
    ${data}=    Get Data From File    ${input_valid_event_in_dmaap}
    Set event in DMaaP    ${data}
    Wait Until Keyword Succeeds    20x    2000ms    Check policy     ${UPDATE_POLICY}


Check BBS log
    [Arguments]    ${searched_log}
    ${status}=    Check for log    ${searched_log}
    Should Be Equal As Strings    ${status}    True

Set PNF name in AAI
    [Arguments]    ${pnfs_name}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=text/html
    ${resp} =    Put Request    ${aai_setup_session}    /set_pnfs    headers=${headers}    data=${pnfs_name}
    Should Be Equal As Strings    ${resp.status_code}    200

Set event in DMaaP
    [Arguments]    ${event_in_dmaap}
    ${resp} =    Put Request    ${dmaap_setup_session}    /set_get_event    headers=${suite_headers}    data=${event_in_dmaap}
    Should Be Equal As Strings    ${resp.status_code}    200

Reset AAI simulator
    ${resp} =    Post Request     ${aai_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200

Reset DMaaP simulator
    ${resp}=    Post Request     ${dmaap_setup_session}    /reset
    Should Be Equal As Strings    ${resp.status_code}    200