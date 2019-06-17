*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords   Create Headers  AND  Create sessions
Test Teardown     Reset Simulators
Test Timeout      2 minutes

Library           resources/PrhLibrary.py
Resource          resources/prh_library.robot
Resource          ../../common.robot

*** Variables ***
${TEST_CASES_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets

${DMAAP_SIMULATOR_SETUP_URL}    http://${DMAAP_SIMULATOR_SETUP}
${AAI_SIMULATOR_SETUP_URL}    http://${AAI_SIMULATOR_SETUP}
${CONSUL_SETUP_URL}    http://${CONSUL_SETUP}
${PRH_URL}  http://localhost:8100
${TRACE_LOG_LEVEL}    {"configuredLevel":"TRACE","effectiveLevel":"TRACE"}
${WARN_LOG_LEVEL}    {"configuredLevel":"WARN","effectiveLevel":"WARN"}

*** Test Cases ***
BBS case event - attachment point
    [Documentation]    PRH get from DMaaP valid event with valid attachment point
    [Tags]    PRH    Valid event    Attachment point
    [Template]    Verify PNF ready sent and logical link created
    ${TEST_CASES_DIR}/ves-event-with-attachment-point

Simple registration event
    [Documentation]    PRH get from DMaaP valid event without valid attachment point
    [Tags]    PRH    Valid event
    [Template]    Verify PNF ready sent
    ${TEST_CASES_DIR}/ves-event-without-additional-fields
    ${TEST_CASES_DIR}/ves-event-with-empty-additional-fields
    ${TEST_CASES_DIR}/ves-event-with-empty-attachment-point

Should not sent PNF ready when DMaaP event is invalid
    [Documentation]    PRH get from DMaaP event with missing required field
    [Tags]    PRH    Invalid event
    [Template]    Verify event with missing required field is logged
    ${TEST_CASES_DIR}/ves-event-missing-field

Should not sent PNF ready when DMaaP event is not JSON array
    [Documentation]    Event from DMaaP is not JSON array
    [Tags]    PRH    Invalid event
    Verify incorrect JSON event is logged    ${TEST_CASES_DIR}/ves-event-not-array

Should not sent PNF ready when AAI record doesn't exist
    [Documentation]    PRH get from DMaaP valid event but given PNF doesn't exists in AAI
    [Tags]    PRH    Missing AAI record
    Verify missing AAI record is logged    ${TEST_CASES_DIR}/aai-missing-entry

Should not sent PNF ready when AAI is not responding
    [Documentation]    PRH get from DMaaP valid event but AAI is not responding
    [Tags]    PRH    AAI not responding
    Verify AAI not responding is logged    ${TEST_CASES_DIR}/aai-not-responding

BBS case event - Re-registration
    [Documentation]    After regitered PNF, PRH reads another one PRH event with registration event
    [Tags]    PRH    Valid event    Re registraiton
    [Template]    Verify PNF re registration
    ${TEST_CASES_DIR}/re-registration

PRH logging level change
    [Documentation]    PRH logging level change from WARN to TRACE
    [Tags]    PRH    logging level
    Verify change logging level