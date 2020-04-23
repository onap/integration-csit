*** Settings ***
Documentation     Testing PMSH functionality

Library           OperatingSystem
Library           RequestsLibrary
Library           String
Library           Process

Resource          ../../common.robot

Test Setup        CreateSessions
Test Teardown     Delete All Sessions


*** Variables ***

${PMSH_BASE_URL}                    https://${PMSH_IP}:8443
${MR_BASE_URL}                      https://${MR_SIM_IP_ADDRESS}:3095
${CBS_BASE_URL}                     https://${CBS_SIM_IP_ADDRESS}:10443
${HEALTHCHECK_ENDPOINT}             /healthcheck

${MR_EXPECTATION_AAI_PNF_CREATED}               %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-aai-pnf-created.json
${MR_EXPECTATION_AAI_PNF_REMOVED}               %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-aai-pnf-deleted.json
${MR_EXPECTATION_POLICY_RESPONSE_PNF_NEW}       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-policy-subscription-created-pnf-new.json
${MR_EXPECTATION_POLICY_RESPONSE_PNF_EXISTING}  %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-policy-subscription-created-pnf-existing.json
${CBS_EXPECTATION_ADMIN_STATE_UNLOCKED}         %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/cbs-expectation-unlocked-config.json

${ADMIN_STATE_LOCKED_PATTERN}       'administrativeState': 'LOCKED'
${ADMIN_STATE_UNLOCKED_PATTERN}     'administrativeState': 'UNLOCKED'
${CLI_EXEC_GET_CBS_CONFIG_FIRST}    docker exec pmsh /bin/sh -c "grep -m 1 'PMSH config from CBS' /var/log/ONAP/dcaegen2/services/pmsh/debug.log"
${CLI_EXEC_GET_CBS_CONFIG_LAST}     docker exec pmsh /bin/sh -c "grep 'PMSH config from CBS' /var/log/ONAP/dcaegen2/services/pmsh/debug.log | tail -1"

${DB_CMD_NETWORK_FUNCTIONS_COUNT}   docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select count(*) from network_functions;'"
${DB_CMD_NF_TO_SUB_REL_COUNT}       docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select count(*) from nf_to_sub_rel;'"
${DB_CMD_SUBSCRIPTIONS_COUNT}       docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select count(*) from subscriptions;'"

${CLI_GET_NETWORK_FUNCTIONS_DB_TABLE}   docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select nf_name, orchestration_status from network_functions;'"
${CLI_GET_NF_TO_SUB_REL_DB_TABLE}       docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select subscription_name, nf_name, nf_sub_status from nf_to_sub_rel;'"
${CLI_GET_SUBSCRIPTIONS_DB_TABLE}       docker exec db bash -c "psql -U pmsh -d pmsh -A -t -c 'select subscription_name, status from subscriptions;'"


*** Test Cases ***

Verify PMSH health check returns 200 and has a status of healthy
    [Tags]                          PMSH_01
    [Documentation]                 Verify the PMSH health check api call functions correctly
    [Timeout]                       10 seconds
    ${resp}=                        Get Request                      pmsh_session  ${HEALTHCHECK_ENDPOINT}
    Should Be True                  ${resp.status_code} == 200
    Should Match Regexp             ${resp.text}             healthy

Verify Administrative State in PMSH log file is LOCKED
    [Tags]                          PMSH_02
    [Documentation]                 Verify Administrative State as logged in PMSH log file is LOCKED
    [Timeout]                       10 seconds
    Sleep                           3       Allow time for PMSH to flush to logs
    ${cli_cmd_output}=              Run Process     ${CLI_EXEC_GET_CBS_CONFIG_FIRST}         shell=yes
    Should Be True                  ${cli_cmd_output.rc} == 0
    Should Contain                  ${cli_cmd_output.stdout}       ${ADMIN_STATE_LOCKED_PATTERN}

Verify database tables exist and are empty
    [Tags]                          PMSH_03
    [Documentation]                 Verify database has been created and is empty
    [Timeout]                       10 seconds
    VerifyDatabaseEmpty

Verify PNF detected in AAI when administrative state unlocked
    [Tags]                          PMSH_04
    [Documentation]                 Verify PNF detected when administrative state unlocked
    [Timeout]                       40 seconds
    SetAdministrativeStateToUnlocked
    Sleep                           31      Allow PMSH time to pick up changes in CBS config
    VerifyCommandOutputContains     ${CLI_EXEC_GET_CBS_CONFIG_LAST}     ${ADMIN_STATE_UNLOCKED_PATTERN}
    VerifyCommandOutputIs           ${cli_get_subscriptions_db_table}       ExtraPM-All-gNB-R2B|UNLOCKED
    VerifyCommandOutputIs           ${cli_get_network_functions_db_table}   pnf-existing|Active
    VerifyCommandOutputIs           ${cli_get_nf_to_sub_rel_db_table}       ExtraPM-All-gNB-R2B|pnf-existing|PENDING_CREATE

Verify Policy response on MR is handled
    [Tags]                          PMSH_05
    [Documentation]                 Verify policy response on MR is handled
    [Timeout]                       40 seconds
    SimulatePolicyResponse          ${MR_EXPECTATION_POLICY_RESPONSE_PNF_EXISTING}
    Sleep                           7 seconds      Ensure Policy response on MR is picked up
    VerifyCommandOutputIs           ${cli_get_nf_to_sub_rel_db_table}       ExtraPM-All-gNB-R2B|pnf-existing|CREATED

Verify AAI event on MR detailing new PNF being detected is handled
    [Tags]                          PMSH_06
    [Documentation]                 Verify PNF created AAI event on MR is handled
    [Timeout]                       30 seconds
    SimulateNewPNF
    Sleep                           12 seconds      Ensure AAI event on MR is picked up
    VerifyCommandOutputIs           ${CLI_GET_SUBSCRIPTIONS_DB_TABLE}       ExtraPM-All-gNB-R2B|UNLOCKED
    VerifyCommandOutputIs           ${CLI_GET_NETWORK_FUNCTIONS_DB_TABLE}   pnf-existing|Active\npnf_newly_discovered|Active
    VerifyCommandOutputIs           ${CLI_GET_NF_TO_SUB_REL_DB_TABLE}       ExtraPM-All-gNB-R2B|pnf-existing|CREATED\nExtraPM-All-gNB-R2B|pnf_newly_discovered|PENDING_CREATE

Verify AAI event on MR detailing PNF being deleted is handled
    [Tags]                          PMSH_07
    [Documentation]                 Verify PNF deleted AAI event on MR is handled
    [Timeout]                       30 seconds
    SimulateDeletedPNF
    Sleep                           12 seconds      Ensure AAI event on MR is picked up
    VerifyNumberOfRecordsInDbTable       ${DB_CMD_NETWORK_FUNCTIONS_COUNT}   1
    VerifyNumberOfRecordsInDbTable       ${DB_CMD_NF_TO_SUB_REL_COUNT}       1

*** Keywords ***

CreateSessions
    Create Session  pmsh_session  ${PMSH_BASE_URL}
    Create Session  mr_sim_session  ${MR_BASE_URL}
    Create Session  cbs_sim_session  ${CBS_BASE_URL}

SetAdministrativeStateToUnlocked
    ${data}=            Get Data From File      ${CBS_EXPECTATION_ADMIN_STATE_UNLOCKED}
    ${resp} =           Put Request             cbs_sim_session  /clear  data={"path": "/service_component_all/.*"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                       Allow CBS time to set expectation
    ${resp} =           Put Request             cbs_sim_session  /expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

VerifyCommandOutputContains
    [Arguments]                     ${cli_command}                  ${string_to_check_for}
    ${cli_cmd_output}=              Run Process                     ${cli_command}         shell=yes
    Should Be True                  ${cli_cmd_output.rc} == 0
    Should Contain                  ${cli_cmd_output.stdout}        ${string_to_check_for}

VerifyCommandOutputIs
    [Arguments]                     ${cli_cmd}          ${expected_contents}
    ${cli_cmd_output}=              Run Process         ${cli_cmd}         shell=yes
    Log             ${cli_cmd_output.stdout}
    Should Be True                  ${cli_cmd_output.rc} == 0
    Should Be Equal As Strings      ${cli_cmd_output.stdout}        ${expected_contents}

SimulateNewPNF
    ${data}=        Get Data From File    ${MR_EXPECTATION_AAI_PNF_CREATED}
    ${resp} =       Put Request     mr_sim_session  /clear  data={"path": "/events/AAI_EVENT/dcae_pmsh_cg/AAI-EVENT"}
    Should Be True      ${resp.status_code} == 200
    ${resp} =       Put Request     mr_sim_session  /expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

SimulatePolicyResponse
    [Arguments]                     ${expected_contents}
    ${data}=        Get Data From File    ${expected_contents}
    ${resp} =       Put Request     mr_sim_session  /clear  data={"path": "/events/org.onap.dmaap.mr.PM_SUBSCRIPTIONS/dcae_pmsh_cg/policy_response_consumer"}
    Should Be True      ${resp.status_code} == 200
    ${resp} =       Put Request     mr_sim_session  /expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

SimulateDeletedPNF
    ${data}=        Get Data From File    ${MR_EXPECTATION_AAI_PNF_REMOVED}
    ${resp} =       Put Request     mr_sim_session  /clear  data={"path": "/events/AAI_EVENT/dcae_pmsh_cg/AAI-EVENT"}
    Should Be True      ${resp.status_code} == 200
    ${resp} =       Put Request     mr_sim_session  /expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

VerifyNumberOfRecordsInDbTable
    [Arguments]         ${db_query}          ${expected_count}
    ${db_count}         Run Process     ${db_query}         shell=yes
    Should Be True      ${db_count.stdout} == ${expected_count}

VerifyDatabaseEmpty
   VerifyNumberOfRecordsInDbTable       ${DB_CMD_NETWORK_FUNCTIONS_COUNT}   0
   VerifyNumberOfRecordsInDbTable       ${DB_CMD_NF_TO_SUB_REL_COUNT}       0
   VerifyNumberOfRecordsInDbTable       ${DB_CMD_SUBSCRIPTIONS_COUNT}       0
