*** Settings ***
Documentation     Integration tests for PRH.
...               PRH receive events from DMaaP and produce or not PNF_READY notification depends on required fields in received event.
Suite Setup       Run keywords   Create Headers  AND  Create sessions   AND    Set default PRH CBS config
Test Teardown     Reset Simulators
Test Timeout      2 minutes

Resource          resources/prh_sessions.robot
Resource          resources/prh_library.robot
Resource          resources/prh_config_library.robot

*** Variables ***
${TEST_CASES_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/assets

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
    ${TEST_CASES_DIR}/ves-event-with-missing-IP-addresses
    ${TEST_CASES_DIR}/ves-event-with-only-IP-addresses
    ${TEST_CASES_DIR}/ves-event-with-empty-additional-fields
    ${TEST_CASES_DIR}/ves-event-with-empty-attachment-point

Should not send PNF ready when DMaaP event is invalid
    [Documentation]    PRH get from DMaaP event with missing required field
    [Tags]    PRH    Invalid event
    [Template]    Verify event with missing required field is logged
    ${TEST_CASES_DIR}/ves-event-missing-field

Should not send PNF ready when DMaaP event is not JSON array
    [Documentation]    Event from DMaaP is not JSON array
    [Tags]    PRH    Invalid event
    Verify incorrect JSON event is logged    ${TEST_CASES_DIR}/ves-event-not-array

Should not send PNF ready when AAI record doesn't exist
    [Documentation]    PRH get from DMaaP valid event but given PNF doesn't exists in AAI
    [Tags]    PRH    Missing AAI record
    Verify missing AAI record is logged    ${TEST_CASES_DIR}/aai-missing-entry

Should not send PNF ready when AAI is not responding
    [Documentation]    PRH get from DMaaP valid event but AAI is not responding
    [Tags]    PRH    AAI not responding
    Verify AAI not responding is logged    ${TEST_CASES_DIR}/aai-not-responding

Should send PNF ready when logical link exists and replace it in AAI
    [Documentation]  PRH gets event from DMaaP with an attachment point, PNF is related to a logical link in AAI
    [Tags]  PRH    Attachment point
    [Template]  Verify PNF ready sent and old logical link replaced in AAI
    ${TEST_CASES_DIR}/pnf-with-existing-logical-link
    ${TEST_CASES_DIR}/pnf-with-different-logical-link

BBS case event - Re-registration
    [Documentation]    After registered PNF, PRH reads another one PRH event with registration event
    [Tags]    PRH    Valid event    Re registraiton
    [Template]    Verify PNF re registration
    ${TEST_CASES_DIR}/re-registration

Should send PNF ready when the associated service instance is non-Active
    [Documentation]  PNF has a non active service instance, should send PNF_READY event
    [Tags]  PRH Service instance non active
    [Template]  Verify PNF ready sent when service instance non active
    ${TEST_CASES_DIR}/service-instance-non-active

PRH logging level change
    [Documentation]    ad-hoc PRH logging level change using rest endpoint
    [Tags]    PRH    logging level
    Verify change logging level
