*** Settings ***
Documentation     Testing PMSH functionality

Library           OperatingSystem
Library           RequestsLibrary
Library           String
Library           Process

Resource          ../../common.robot
Test Teardown     Delete All Sessions


*** Variables ***

${PMSH_BASE_URL}                    https://${PMSH_IP}:8443
${MR_BASE_URL}                      http://${MR_IP_ADDRESS}:3904
${CBS_BASE_URL}                     https://${CBS_SIM_IP_ADDRESS}:10443
${SUBSCRIPTIONS_ENDPOINT}           /subscriptions
${SUBSCRIPTION_ENDPOINT}            /subscription
${POLICY_PUBLISH_MR_TOPIC}          /events/unauthenticated.PMSH_CL_INPUT
${AAI_MR_TOPIC}                     /events/AAI_EVENT

${MR_AAI_PNF_CREATED}                       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/aai-pnf-create.json
${MR_AAI_PNF_REMOVED}                       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/aai-pnf-delete.json
${MR_POLICY_RESPONSE_PNF_EXISTING}          %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/policy-sub-created-pnf-existing.json
${CBS_EXPECTATION_ADMIN_STATE_UNLOCKED}     %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/cbs-expectation-unlocked-config.json
${CREATE_SUBSCRIPTION_DATA}                 %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_request.json
${CREATE_SUBSCRIPTION_BAD_DATA}             %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_bad_request.json
${CREATE_SUBSCRIPTION_SCHEMA_ERROR_DATA}    %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_schema_error_request.json
${ADMIN_STATE_LOCKED_PATTERN}       'administrativeState': 'LOCKED'
${CLI_EXEC_GET_CBS_CONFIG_FIRST}    docker exec pmsh /bin/sh -c "grep -m 1 'PMSH config from CBS' /var/log/ONAP/dcaegen2/services/pmsh/application.log"

*** Test Cases ***

Verify Create Subscription API
    [Tags]                          PMSH_07
    [Documentation]                 Verify Create Subscription API
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SUBSCRIPTION_DATA}
    ${resp}=                        PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    Should Be True                  ${resp.status_code} == 201

Verify database tables exist and are empty
    [Tags]                          PMSH_02
    [Documentation]                 Verify database has been created and is empty
    [Timeout]                       10 seconds
    ${resp}=                        GetSubsCall    ${SUBSCRIPTIONS_ENDPOINT}
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.text}                     []

Verify PNF detected in AAI when administrative state unlocked
    [Tags]                          PMSH_03
    [Documentation]                 Verify PNF detected when administrative state unlocked
    [Timeout]                       60 seconds
    SetAdministrativeStateToUnlocked
    Sleep                           31             Allow PMSH time to pick up changes in CBS config
    ${resp}=                        GetSubsCall    ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[1]['subscription_status']}                        UNLOCKED
    Should Be Equal As Strings      ${resp.json()[1]['network_functions'][0]['nf_name']}            pnf-existing
    Should Be Equal As Strings      ${resp.json()[1]['network_functions'][0]['nf_sub_status']}      PENDING_CREATE

Verify Policy response on MR is handled
    [Tags]                          PMSH_04
    [Documentation]                 Verify policy response on MR is handled
    [Timeout]                       60 seconds
    SimulatePolicyResponse          ${MR_POLICY_RESPONSE_PNF_EXISTING}
    Sleep                           31 seconds      Ensure Policy response on MR is picked up
    ${resp}=                        GetSubsCall     ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[1]['network_functions'][0]['nf_sub_status']}      PENDING_CREATE

Verify AAI event on MR detailing new PNF being detected is handled
    [Tags]                          PMSH_05
    [Documentation]                 Verify PNF created AAI event on MR is handled
    [Timeout]                       60 seconds
    SimulateNewPNF                  ${MR_AAI_PNF_CREATED}
    Sleep                           31 seconds      Ensure AAI event on MR is picked up
    ${resp}=                        GetSubsCall     ${SUBSCRIPTIONS_ENDPOINT}
    Should Be Equal As Strings      ${resp.json()[1]['network_functions'][1]['nf_name']}            pnf_newly_discovered
    Should Be Equal As Strings      ${resp.json()[1]['network_functions'][1]['nf_sub_status']}      PENDING_CREATE

Verify AAI event on MR detailing PNF being deleted is handled
    [Tags]                          PMSH_06
    [Documentation]                 Verify PNF deleted AAI event on MR is handled
    [Timeout]                       60 seconds
    SimulateDeletedPNF              ${MR_AAI_PNF_REMOVED}
    Sleep                           31 seconds      Ensure AAI event on MR is picked up
    ${resp}=                        GetSubsCall     ${SUBSCRIPTIONS_ENDPOINT}
    Should Not Contain              ${resp.text}    pnf_newly_discovered

Verify Create Subscription API for duplicate subscription Id
    [Tags]                          PMSH_08
    [Documentation]                 Verify Create Subscription API
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SUBSCRIPTION_DATA}
    ${resp}=                        PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    Should Be True                  ${resp.status_code} == 409
    Should Contain                  ${resp.json()}      subscription Name: subs_01 already exists.

Verify Create Subscription API for schema error
    [Tags]                          PMSH_09
    [Documentation]                 Verify Create Subscription API
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SUBSCRIPTION_SCHEMA_ERROR_DATA}
    ${resp}=                        PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    Should Be True                  ${resp.status_code} == 400
    Should Contain                  ${resp.json()['detail']}      'administrativeState' is a required property - 'subscription.measurementGroups.0.measurementGroup'

Verify Create Subscription API for filter values missing
    [Tags]                          PMSH_10
    [Documentation]                 Verify Create Subscription API
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SUBSCRIPTION_BAD_DATA}
    ${resp}=                        PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    Should Be True                  ${resp.status_code} == 400
    Should Contain                  ${resp.json()}      At least one filter within nfFilter must not be empty

*** Keywords ***

SetAdministrativeStateToUnlocked
    ${data}=            Get Data From File      ${CBS_EXPECTATION_ADMIN_STATE_UNLOCKED}
    Create Session      cbs_sim_session   ${CBS_BASE_URL}    verify=false
    ${resp}=            PUT On Session    cbs_sim_session    url=/clear  data={"path": "/service_component_all/.*"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                 Allow CBS time to set expectation
    ${resp} =           PUT On Session    cbs_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201


SimulatePolicyResponse
    [Arguments]                     ${expected_contents}
    ${json_value}=                  json_from_file                  ${expected_contents}
    ${resp}=    			  	  	PostMrCall      			    ${POLICY_PUBLISH_MR_TOPIC}     ${json_value}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			'JSON Response Code:'${resp}

SimulateNewPNF
    [Arguments]                     ${expected_contents}
    ${json_value}=                  json_from_file                  ${expected_contents}
    ${resp}=    			  	  	PostMrCall      				${AAI_MR_TOPIC}      ${json_value}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			'JSON Response Code:'${resp}

SimulateDeletedPNF
    [Arguments]                     ${expected_contents}
    ${json_value}=                  json_from_file                  ${expected_contents}
    ${resp}=    			  	  	PostMrCall      				${AAI_MR_TOPIC}      ${json_value}
    log    				          	${resp.text}
    Should Be Equal As Strings    	${resp.status_code}           	200
    ${count}=    	              	Evaluate     					$resp.json().get('count')
    log    				  			'JSON Response Code:'${resp}

PostMrCall
    [Arguments]     ${url}     ${data}
    Create Session  mr_sim_session       ${MR_BASE_URL}    verify=false
    ${headers}=     Create Dictionary    Accept=application/json     Content-Type=application/json
    ${resp}=        POST On Session      mr_sim_session    url=${url}    json=${data}     headers=${headers}
    [Return]        ${resp}

GetSubsCall
    [Arguments]     ${url}
    Create Session  pmsh_session      ${PMSH_BASE_URL}    verify=false
    ${resp}=        GET On Session    pmsh_session        url=${url}
    [Return]        ${resp}

PostSubscriptionCall
    [Arguments]     ${url}     ${data}
    Create Session  pmsh_sub_session       ${PMSH_BASE_URL}    verify=false
    ${headers}=     Create Dictionary    Accept=application/json     Content-Type=application/json
    ${resp}=        POST On Session      pmsh_sub_session    url=${url}    json=${data}     headers=${headers}  expected_status=anything
    [Return]        ${resp}
