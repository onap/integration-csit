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
${SUBSCRIPTIONS_ENDPOINT}           /subscriptions

${MR_EXPECTATION_AAI_PNF_CREATED}               %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-aai-pnf-created.json
${MR_EXPECTATION_AAI_PNF_REMOVED}               %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-aai-pnf-deleted.json
${MR_EXPECTATION_POLICY_RESPONSE_PNF_NEW}       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-policy-subscription-created-pnf-new.json
${MR_EXPECTATION_POLICY_RESPONSE_PNF_EXISTING}  %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-expectation-policy-subscription-created-pnf-existing.json
${CBS_EXPECTATION_ADMIN_STATE_UNLOCKED}         %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/cbs-expectation-unlocked-config.json

${ADMIN_STATE_LOCKED_PATTERN}       'administrativeState': 'LOCKED'
${CLI_EXEC_GET_CBS_CONFIG_FIRST}    docker exec pmsh /bin/sh -c "grep -m 1 'PMSH config from CBS' /var/log/ONAP/dcaegen2/services/pmsh/application.log"

*** Test Cases ***

Verify Administrative State in PMSH log file is LOCKED
    [Tags]                          PMSH_01
    [Documentation]                 Verify Administrative State as logged in PMSH log file is LOCKED
    [Timeout]                       10 seconds
    Sleep                           3       Allow time for PMSH to flush to logs
    ${cli_cmd_output}=              Run Process     ${CLI_EXEC_GET_CBS_CONFIG_FIRST}         shell=yes
    Should Be True                  ${cli_cmd_output.rc} == 0
    Should Contain                  ${cli_cmd_output.stdout}       ${ADMIN_STATE_LOCKED_PATTERN}

Verify database tables exist and are empty
    [Tags]                          PMSH_02
    [Documentation]                 Verify database has been created and is empty
    [Timeout]                       10 seconds
    ${resp}=                        Get Request                      pmsh_session  ${SUBSCRIPTIONS_ENDPOINT}
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.text}                     []

Verify PNF detected in AAI when administrative state unlocked
    [Tags]                          PMSH_03
    [Documentation]                 Verify PNF detected when administrative state unlocked
    [Timeout]                       40 seconds
    SetAdministrativeStateToUnlocked
    Sleep                           31      Allow PMSH time to pick up changes in CBS config
    ${resp}=                        Get Request                      pmsh_session  ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[0]['subscription_status']}                            UNLOCKED
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][0]['nf_name']}                pnf-existing
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][0]['orchestration_status']}   Active
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][0]['nf_sub_status']}          PENDING_CREATE

Verify Policy response on MR is handled
    [Tags]                          PMSH_04
    [Documentation]                 Verify policy response on MR is handled
    [Timeout]                       40 seconds
    SimulatePolicyResponse          ${MR_EXPECTATION_POLICY_RESPONSE_PNF_EXISTING}
    Sleep                           7 seconds      Ensure Policy response on MR is picked up
    ${resp}=                        Get Request                      pmsh_session  ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][0]['nf_sub_status']}     CREATED

Verify AAI event on MR detailing new PNF being detected is handled
    [Tags]                          PMSH_05
    [Documentation]                 Verify PNF created AAI event on MR is handled
    [Timeout]                       30 seconds
    SimulateNewPNF
    Sleep                           12 seconds      Ensure AAI event on MR is picked up
    ${resp}=                        Get Request                      pmsh_session  ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][1]['nf_name']}            pnf_newly_discovered
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][1]['orchestration_status']}   Active
    Should Be Equal As Strings      ${resp.json()[0]['network_functions'][1]['nf_sub_status']}          PENDING_CREATE

Verify AAI event on MR detailing PNF being deleted is handled
    [Tags]                          PMSH_06
    [Documentation]                 Verify PNF deleted AAI event on MR is handled
    [Timeout]                       30 seconds
    SimulateDeletedPNF
    Sleep                           12 seconds      Ensure AAI event on MR is picked up
    ${resp}=                        Get Request                      pmsh_session  ${SUBSCRIPTIONS_ENDPOINT}
    Should Not Contain              ${resp.text}            pnf_newly_discovered

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
