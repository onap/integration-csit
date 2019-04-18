*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords   Create header  AND  Create sessions  AND  Ensure Container Is Running  prh  AND  Ensure Container Is Exited  ssl_prh
Suite Teardown    Ensure Container Is Running  ssl_prh
Test Teardown     Reset Simulators
Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot
Resource          ../../common.robot

*** Variables ***
${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${CONSUL_SETUP_URL}    http://${CONSUL_SETUP}

${VES_EVENT_PNF_REGISTRATION_SIMPLE}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/ves-event-pnf-registration-simple.json
${AAI_PNF_REGISTRATION_SIMPLE}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/aai-pnf-registration-simple.json
${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_all_fields.json
${EVENT_WITH_IPV4}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV4.json
${EVENT_WITH_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV6.json
${EVENT_WITH_MISSING_IPV4_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_IPV4_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV4}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV4.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME_IPV4_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_IPV4_and_IPV6.json
${EVENT_WITH_OPTIONAL_REGISTRATION_FIELDS_ALL_FILLED}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_optional_registration_fields_all_filled.json
${EVENT_WITH_OPTIONAL_REGISTRATION_FIELDS_EMPTY}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_optional_registration_fields_empty.json
${EVENT_WITH_OPTIONAL_REGISTRATION_FIELDS_MISSING_ALL}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_optional_registration_fields_missing_all.json
${EVENT_WITH_OPTIONAL_REGISTRATION_FIELDS_MISSING_PARTIAL}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_optional_registration_fields_missing_partial.json
${EVENT_WITHOUT_IPV6_FILED}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_without_IPV6_field.json
${Not_json_format}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/not_json_format.json

*** Test Cases ***

Event in DMaaP is not JSON format
    [Documentation]    PRH get not JSON format event from DMaaP - PRH does not produce PNF_READY notification
    [Tags]    PRH
    [Timeout]    150s
    Sleep    90s
    ${data}=    Get Data From File    ${Not_json_format}
    Set event in DMaaP    ${data}
    #TODO hangs up build
    Wait Until Keyword Succeeds    10x    3000ms    Check PRH log    |java.lang.IllegalStateException: Not a JSON Array:


