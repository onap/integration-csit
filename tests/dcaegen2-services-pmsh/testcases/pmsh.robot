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
${MR_SIM_BASE_URL}                  http://${MR_SIM_IP_ADDRESS}:3904
${SUBSCRIPTION_ENDPOINT}            /subscription

${MR_SIM_RESET}                             %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/mr-sim-reset.json
${MR_AAI_PNF_CREATED}                       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/aai-pnf-create.json
${MR_AAI_PNF_REMOVED}                       %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/aai-pnf-delete.json
${MR_POLICY_RESPONSE_PNF_EXISTING}          %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/policy-sub-created-pnf-existing.json
${MR_POLICY_RESPONSE_PNF_DELETED}           %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/policy-sub-deleted-pnf-existing.json
${CREATE_SUBSCRIPTION_DATA}                 %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_request.json
${CREATE_SECOND_SUBSCRIPTION_DATA}          %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_second_subscription_request.json
${CREATE_SUBSCRIPTION_BAD_DATA}             %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_bad_request.json
${CREATE_SUBSCRIPTION_SCHEMA_ERROR_DATA}    %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_subscription_schema_error_request.json
${CREATE_MSG_GRP_DATA}                      %{WORKSPACE}/tests/dcaegen2-services-pmsh/testcases/assets/create_msg_grp.json

*** Test Cases ***
Verify Get subscriptions with Network Functions None
    [Tags]                          PMSH_01
    [Documentation]                 Verify Get all subscriptions when there are no defined subscriptions
    [Timeout]                       10 seconds
    ${resp}=                        GetSubsCall    ${SUBSCRIPTION_ENDPOINT}     ""
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.text}                     []

Verify Create Subscriptions API
    [Tags]                          PMSH_07
    [Documentation]                 Verify Create Subscription API
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SUBSCRIPTION_DATA}
    ${resp}=                        PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    Should Be True                  ${resp.status_code} == 201
     ${resp}=                       GetSubsCall    ${SUBSCRIPTION_ENDPOINT}   "/subs_01"
    Should Be Equal As Strings      ${resp.json()[0]['subscription']['subscriptionName']}       subs_01

Verify database tables exist and are empty
    [Tags]                          PMSH_02
    [Documentation]                 Verify database has been created and is empty
    [Timeout]                       10 seconds
    ${resp}=                        GetSubsCall    ${SUBSCRIPTION_ENDPOINT}     ""
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.text}                     []

Verify PNF detected in AAI when administrative state unlocked
    [Tags]                          PMSH_03
    [Documentation]                 Verify PNF detected when administrative state unlocked
    [Timeout]                       60 seconds
    ${resp}=                        GetMeasGrpCall    /subscription/subs_01/measurementGroups/msg_grp_01
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       UNLOCKED
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}            pnf-existing
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfMgStatus']}      PENDING_CREATE

Verify Policy response on MR is handled
    [Tags]                          PMSH_04
    [Documentation]                 Verify policy response on MR is handled
    [Timeout]                       60 seconds
    AddCreatePolicyResponeToMrSim
    Sleep                           31 seconds      Ensure Policy response on MR is picked up
    ResetMrSim
    ${resp}=                        GetMeasGrpCall    /subscription/subs_01/measurementGroups/msg_grp_01
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       UNLOCKED
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}            pnf-existing
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfMgStatus']}     CREATED

Verify AAI event on MR detailing new PNF being detected is handled
    [Tags]                          PMSH_05
    [Documentation]                 Verify PNF created AAI event on MR is handled
    [Timeout]                       60 seconds
    AddNewPnfToMrSim
    Sleep                           25 seconds     Give sim time to set expectation
    ResetMrSim
    ${resp}=                        GetMeasGrpCall    /subscription/subs_01/measurementGroups/msg_grp_01
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       UNLOCKED
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][1]['nfName']}            pnf_newly_discovered
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][1]['nfMgStatus']}      PENDING_CREATE

Verify AAI event on MR detailing PNF being deleted is handled
    [Tags]                          PMSH_06
    [Documentation]                 Verify PNF deleted AAI event on MR is handled
    [Timeout]                       60 seconds
    RemoveNewPnfFromMrSim
    Sleep                           21 seconds      Ensure AAI event on MR is picked up
    ResetMrSim
    ${resp}=                        GetMeasGrpCall    /subscription/subs_01/measurementGroups/msg_grp_01
    Should Not Contain              ${resp.text}    pnf_newly_discovered

Verify Create Subscription API for duplicate subscription Id
    [Tags]                          PMSH_08
    [Documentation]                 Verify Create Subscription API for duplicate subscription Id
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

Verify Get Measurement Group with Network Functions
    [Tags]                          PMSH_11
    [Documentation]                 Verify Get Measurement Group with Network Functions by using MGName and SubName
    [Timeout]                       60 seconds
    ${resp}=                        GetMeasGrpWithNFSCall     /subscription/subs_01/measurementGroups/msg_grp_01
    ${nf_length}=                   Get length  ${resp.json()['networkFunctions']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['measurementGroupName']}      msg_grp_01
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}      pnf-existing
    Should be equal as numbers      ${nf_length}  1

Verify Get single subscription with Network Functions
    [Tags]                          PMSH_12
    [Documentation]                 Verify Get single subscription with Network Functions by using subscription name
    [Timeout]                       60 seconds
    ${resp}=                        GetSubsCall    ${SUBSCRIPTION_ENDPOINT}/subs_01  ""
    ${nf_length}=                   Get length  ${resp.json()['subscription']['nfs']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()['subscription']['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['subscription']['nfs'][0]}      pnf-existing
	Should Be Equal As Strings      ${resp.json()['subscription']['measurementGroups'][0]['measurementGroup']['measurementGroupName']}  msg_grp_02
    Should be equal as numbers      ${nf_length}  1

Verify Get single subscription with Network Functions None
    [Tags]                          PMSH_13
    [Documentation]                 Verify Get single subscription with Network Functions when there is no defined subscription
    [Timeout]                       60 seconds
    ${resp}=                        GetSubsCall    ${SUBSCRIPTION_ENDPOINT}/sub_none  ""
    Should Be True                  ${resp.status_code} == 404
    Should Be Equal As Strings      ${resp.json()['error']}     Subscription was not defined with the name : sub_none

Verify Update Measurement Group admin status from Unlocked to Locking
    [Tags]                          PMSH_14
    [Documentation]                 Verify Update Measurement Group admin status from Unlocked to Locking
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "LOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_01/adminState   ${json}
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.json()}      Successfully updated admin state
    ${resp}=                        GetMeasGrpWithNFSCall     /subscription/subs_01/measurementGroups/msg_grp_01
    ${nf_length}=                   Get length  ${resp.json()['networkFunctions']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['measurementGroupName']}      msg_grp_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       LOCKING
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}      pnf-existing
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfMgStatus']}      PENDING_DELETE
    Should be equal as numbers      ${nf_length}  1

Verify Update Measurement Group admin status with locking in progress
    [Tags]                          PMSH_15
    [Documentation]                 Verify Update Measurement Group admin status with locking in progress
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "LOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_01/adminState   ${json}
    Should Be True                  ${resp.status_code} == 409
    Should Contain                  ${resp.json()}  Cannot update admin status as Locked request is in progress for sub name: subs_01  and meas group name: msg_grp_01

Verify Measurement Group admin status update from Locking to Locked
    [Tags]                          PMSH_16
    [Documentation]                 Verify Measurement Group admin status update from Locking to Locked
    [Timeout]                       60 seconds
    AddDeletePolicyResponeToMrSim
    Sleep                           31 seconds      Ensure Policy response on MR is picked up
    ResetMrSim
    ${resp}=                        GetMeasGrpCall    /subscription/subs_01/measurementGroups/msg_grp_01
    Should Be Equal As Strings      ${resp.json()['measurementGroupName']}      msg_grp_01
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       LOCKED
    ${nf_length}=                   Get length  ${resp.json()['networkFunctions']}
    Should be equal as numbers      ${nf_length}  0

Verify Update Measurement Group admin status to unlocked
    [Tags]                          PMSH_17
    [Documentation]                 Verify Update Measurement Group admin status to unlocked with no Network Functions in Subscription
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "UNLOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_01/adminState   ${json}
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.json()}      Successfully updated admin state
    ${resp}=                        GetMeasGrpWithNFSCall     /subscription/subs_01/measurementGroups/msg_grp_01
    ${nf_length}=                   Get length  ${resp.json()['networkFunctions']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['measurementGroupName']}      msg_grp_01
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       UNLOCKED
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}      pnf-existing
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfMgStatus']}      PENDING_CREATE
    Should be equal as numbers      ${nf_length}  1

Verify Update Measurement Group admin status from Locked to Unlocked with Network function present in subscription
    [Tags]                          PMSH_18
    [Documentation]                 Verify Update Measurement Group admin status from Locked to Unlocked with Network function present in subscription
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "UNLOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_02/adminState   ${json}
    Should Be True                  ${resp.status_code} == 200
    Should Contain                  ${resp.json()}      Successfully updated admin state
    ${resp}=                        GetMeasGrpWithNFSCall     /subscription/subs_01/measurementGroups/msg_grp_02
    ${nf_length}=                   Get length  ${resp.json()['networkFunctions']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()['measurementGroupName']}      msg_grp_02
    Should Be Equal As Strings      ${resp.json()['administrativeState']}       UNLOCKED
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfName']}      pnf-existing
    Should Be Equal As Strings      ${resp.json()['networkFunctions'][0]['nfMgStatus']}      PENDING_CREATE
    Should be equal as numbers      ${nf_length}  1

Verify Update Measurement Group admin status with no change
    [Tags]                          PMSH_19
    [Documentation]                 Verify Update Measurement Group admin status with no change
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "UNLOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_01/adminState   ${json}
    Should Be True                  ${resp.status_code} == 400
    Should Contain                  ${resp.json()}  Measurement group is already in UNLOCKED state for sub name: subs_01  and meas group name: msg_grp_01

Verify Update Measurement Group admin status for invalid measurement group
    [Tags]                          PMSH_20
    [Documentation]                 Verify Update Measurement Group admin status for invalid measurement group
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "LOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    ${resp}=                        PutMsgGrpStatusCall     /subscription/subs_01/measurementGroups/msg_grp_11/adminState   ${json}
    Should Be True                  ${resp.status_code} == 400
    Should Contain                  ${resp.json()}  Requested measurement group not available for admin status update

Verify Get subscriptions with Network Functions
    [Tags]                          PMSH_21
    [Documentation]                 Verify Get subscriptions with Network Functions
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_SECOND_SUBSCRIPTION_DATA}
    ${resp_post}=                   PostSubscriptionCall     ${SUBSCRIPTION_ENDPOINT}   ${json_value}
    ${resp}=                        GetSubsCall    ${SUBSCRIPTION_ENDPOINT}  ""
    ${nf_length_first}=             Get length  ${resp.json()[0]['subscription']['nfs']}
    ${nf_length_second}=            Get length  ${resp.json()[1]['subscription']['nfs']}
    Should Be True                  ${resp.status_code} == 200
    Should Be Equal As Strings      ${resp.json()[0]['subscription']['subscriptionName']}      subs_01
    Should Be Equal As Strings      ${resp.json()[0]['subscription']['nfs'][0]}      pnf-existing
	Should Be Equal As Strings      ${resp.json()[0]['subscription']['measurementGroups'][0]['measurementGroup']['measurementGroupName']}  msg_grp_02
    Should be equal as numbers      ${nf_length_first}  1
    Should Be Equal As Strings      ${resp.json()[1]['subscription']['subscriptionName']}      subs_02
    Should Be Equal As Strings      ${resp.json()[1]['subscription']['nfs'][0]}      pnf-existing
	Should Be Equal As Strings      ${resp.json()[1]['subscription']['measurementGroups'][0]['measurementGroup']['measurementGroupName']}  msg_grp_04
    Should be equal as numbers      ${nf_length_second}  1

Verify Delete Measurement Group with Administrative State unlocked
    [Tags]                          PMSH_22
    [Documentation]                 Verify Delete Measurement Group with Administrative State unlocked
    [Timeout]                       60 seconds
    ${json_string}=                 Set Variable    {"administrativeState": "UNLOCKED"}
    ${json}=                        evaluate        json.loads('''${json_string}''')    json
    PutMsgGrpStatusCall             /subscription/subs_01/measurementGroups/msg_grp_02/adminState   ${json}
    ${resp}=                        DeleteMeasGrpCall   /subscription/subs_01/measurementGroups/msg_grp_02
    Should Be True                  ${resp.status_code} == 409

Verify Delete Measurement Group with incorrect Measurement Group name server error
    [Tags]                          PMSH_23
    [Documentation]                 Verify Delete Measurement Group with incorrect Measurement Group Name
    [Timeout]                       60 seconds
    ${resp}=                        DeleteMeasGrpCall   /subscription/subs_01/measurementGroups/nonexistent
    Should Be True                  ${resp.status_code} == 500

Verify Create Measurement Group successful
    [Tags]                          PMSH_24
    [Documentation]                 Verify Create Measurement Group successful
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_MSG_GRP_DATA}
    ${resp}=                        PostMsgGrpCall      /subscription/subs_01/measurementGroups/msg_grp_05  ${json_value}
    Should Be True                  ${resp.status_code} == 201

Verify Create Measurement Group unsuccessful
    [Tags]                          PMSH_25
    [Documentation]                 Verify Create Measurement Group successful
    [Timeout]                       60 seconds
    ${json_value}=                  json_from_file                  ${CREATE_MSG_GRP_DATA}
    ${resp}=                        PostMsgGrpCall      /subscription/subs_01/measurementGroups/msg_grp_05  ${json_value}
    Should Be True                  ${resp.status_code} == 409

Verify Delete Measurement Group successful
    [Tags]                          PMSH_26
    [Documentation]                 Verify Delete Measurement Group successful
    [Timeout]                       60 seconds
    ${resp}=                        DeleteMeasGrpCall   /subscription/subs_01/measurementGroups/msg_grp_05
    Should Be True                  ${resp.status_code} == 204

*** Keywords ***

AddCreatePolicyResponeToMrSim
    ${data}=            Get Data From File      ${MR_POLICY_RESPONSE_PNF_EXISTING}
    Create Session      mr_sim_session   ${MR_SIM_BASE_URL}    verify=false
    ${resp}=            PUT On Session    mr_sim_session    url=/clear  data={"id" : "pmsh_cl_input_event"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                 Allow MR_SIM time to set expectation
    ${resp} =           PUT On Session    mr_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

AddDeletePolicyResponeToMrSim
    ${data}=            Get Data From File      ${MR_POLICY_RESPONSE_PNF_DELETED}
    Create Session      mr_sim_session   ${MR_SIM_BASE_URL}    verify=false
    ${resp}=            PUT On Session    mr_sim_session    url=/clear  data={"id" : "pmsh_cl_input_event"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                 Allow MR_SIM time to set expectation
    ${resp} =           PUT On Session    mr_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

AddNewPnfToMrSim
    ${data}=            Get Data From File      ${MR_AAI_PNF_CREATED}
    Create Session      mr_sim_session   ${MR_SIM_BASE_URL}    verify=false
    ${resp}=            PUT On Session    mr_sim_session    url=/clear  data={"id" : "mr_aai_event"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                 Allow MR_SIM time to set expectation
    ${resp} =           PUT On Session    mr_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

RemoveNewPnfFromMrSim
    ${data}=            Get Data From File      ${MR_AAI_PNF_REMOVED}
    Create Session      mr_sim_session   ${MR_SIM_BASE_URL}    verify=false
    ${resp}=            PUT On Session    mr_sim_session    url=/clear  data={"id" : "mr_aai_event"}
    Should Be True      ${resp.status_code} == 200
    Sleep               2                 Allow MR_SIM time to set expectation
    ${resp} =           PUT On Session    mr_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

ResetMrSim
    ${data}=            Get Data From File      ${MR_SIM_RESET}
    Create Session      mr_sim_session   ${MR_SIM_BASE_URL}    verify=false
    ${resp}=            PUT On Session    mr_sim_session    url=/reset
    Should Be True      ${resp.status_code} == 200
    ${resp}=            PUT On Session    mr_sim_session    url=/expectation     data=${data}
    Should Be True      ${resp.status_code} == 201

GetSubsCall
    [Arguments]     ${url}      ${url_path_param}
    Create Session  pmsh_session      ${PMSH_BASE_URL}    verify=false
    ${resp}=        GET On Session    pmsh_session        url=${url}    data={"path": {url_path_param}}    expected_status=any
    [Return]        ${resp}

GetMeasGrpCall
    [Arguments]     ${url}
    Create Session  pmsh_session      ${PMSH_BASE_URL}    verify=false
    ${resp}=        GET On Session    pmsh_session        url=${url}
    [Return]        ${resp}

GetMeasGrpWithNFSCall
    [Arguments]     ${url}
    Create Session  pmsh_session      ${PMSH_BASE_URL}    verify=false
    ${resp}=        GET On Session    pmsh_session        url=${url}
    [Return]        ${resp}

DeleteMeasGrpCall
    [Arguments]     ${url}
    Create Session  pmsh_session      ${PMSH_BASE_URL}    verify=false
    ${resp}=        DELETE On Session    pmsh_session        url=${url}     expected_status=anything
    [Return]        ${resp}

PostSubscriptionCall
    [Arguments]     ${url}     ${data}
    Create Session  pmsh_sub_session       ${PMSH_BASE_URL}    verify=false
    ${headers}=     Create Dictionary    Accept=application/json     Content-Type=application/json
    ${resp}=        POST On Session      pmsh_sub_session    url=${url}    json=${data}     headers=${headers}  expected_status=anything
    [Return]        ${resp}

PostMsgGrpCall
    [Arguments]     ${url}     ${data}
    Create Session  pmsh_sub_session       ${PMSH_BASE_URL}    verify=false
    ${headers}=     Create Dictionary    Accept=application/json     Content-Type=application/json
    ${resp}=        POST On Session      pmsh_sub_session    url=${url}    json=${data}     headers=${headers}  expected_status=anything
    [Return]        ${resp}

PutMsgGrpStatusCall
    [Arguments]     ${url}     ${data}
    Create Session  pmsh_sub_session       ${PMSH_BASE_URL}    verify=false
    ${headers}=     Create Dictionary    Accept=application/json     Content-Type=application/json
    ${resp}=        PUT On Session      pmsh_sub_session    url=${url}    json=${data}     headers=${headers}  expected_status=anything
    [Return]        ${resp}
