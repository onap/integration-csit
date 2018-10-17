*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords    Create header    Create sessions
Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot
Resource          ../../common.robot

*** Variables ***
${DMAAP_SIMULATOR_URL}    http://${DMAAP_SIMULATOR}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_all_fields.json
${EVENT_WITH_IPV4}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV4.json
${EVENT_WITH_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_IPV6.json
${EVENT_WITH_MISSING_IPV4_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_IPV4_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV4}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV4.json
${EVENT_WITH_MISSING_SOURCENAME_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_and_IPV6.json
${EVENT_WITH_MISSING_SOURCENAME_IPV4_AND_IPV6}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_with_missing_sourceName_IPV4_and_IPV6.json
${EVENT_WITHOUT_IPV6_FILED}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/event_without_IPV6_field.json
${Not_json_format}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets/json_events/not_json_format.json

*** Test Cases ***
#Valid DMaaP event can be converted to PNF_READY notification with ssl connection to AAI
#    [Documentation]    PRH get valid event from DMaaP with required fields - PRH produce PNF_READY notification
#    [Tags]    PRH    Valid event
#    [Template]    Valid event processing
#    ${EVENT_WITH_ALL_VALID_REQUIRED_FIELDS}
#    ${EVENT_WITH_IPV4}
#    ${EVENT_WITH_IPV6}
#    ${EVENT_WITHOUT_IPV6_FILED}
