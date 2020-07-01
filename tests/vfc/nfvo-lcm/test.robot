*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTPS
Library     ONAPLibrary.Utilities

*** Variables ***
@{return_ok_list}=   200  201  202  204
${queryswagger_url}    /api/nslcm/v1/swagger.json
${ns_url}          /api/nslcm/v1/ns
${get_subscriptions_url}          /api/nslcm/v1/subscriptions
${healthcheck_url}     /api/nslcm/v1/health_check
${get_job_url}     /api/nslcm/v1/jobs
${vnfs_url}     /api/nslcm/v1/ns/vnfs
${terminate_vnfs_url}     /api/nslcm/v1/ns/terminatevnf
${vls_url}     /api/nslcm/v1/ns/vls
${sfcs_url}     /api/nslcm/v1/ns/sfcs
${pnfs_url}     /api/nslcm/v1/pnfs

${ns_instances_url}    /api/nslcm/v1/ns_instances

#json files
${create_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_ns.json
${heal_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/heal_ns.json
${scale_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/scale_ns.json
${update_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/update_ns.json
${terminate_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_ns.json
${create_vnf_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_vnf.json
${terminate_vnf_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_vnf.json
${create_vl_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_vl.json
${create_subscriptions_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_subscription.json

${create_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_ns_instance.json
${terminate_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_ns_instance.json
${update_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/update_ns_instance.json

#global variables
${nsInstId}
${jobInstId}
${vnfInstId}
${vlInstId}
${nsInstanceId}

*** Test Cases ***
NslcmSwaggerTest
    [Documentation]    query swagger info of nslcm
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

NslcmSwaggerByMSBTest
    [Documentation]    query swagger info of nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

CreateNSTest
    [Documentation]    Create NS function test
    ${json_value}=     json_from_file      ${create_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstId}=    Convert To String      ${response_json['nsInstanceId']}
    Set Global Variable     ${nsInstId}

CreateVnfTest
    [Documentation]    Create vnf function test
    ${json_value}=     json_from_file      ${create_vnf_json}
    Set To Dictionary    ${json_value}    nsInstanceId=${nsInstId}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${vnfs_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vnfInstId}=    Convert To String      ${response_json['vnfInstId']}
    Set Global Variable     ${vnfInstId}

QueryVnfTest
    [Documentation]    Query vnf function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${vnfs_url}/${vnfInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateVnfTest
    [Documentation]    Terminate vnf function test
    ${json_value}=     json_from_file      ${terminate_vnf_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${terminate_vnfs_url}/${vnfInstId}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CreateVlTest
    [Documentation]    Create vl function test
    ${json_value}=     json_from_file      ${create_vl_json}
    Set To Dictionary    ${json_value}    nsInstanceId=${nsInstId}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${vls_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vlInstId}=    Convert To String      ${response_json['vlId']}
    Set Global Variable     ${vlInstId}

DeleteVlTest
    [Documentation]    Delete vl function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    Delete Request    web_session     ${vls_url}/${vlInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

ScaleNSTest
    [Documentation]    Scale Ns function test
    ${json_value}=     json_from_file      ${scale_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_url}/${nsInstId}/scale    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

HealNSTest
    [Documentation]    Heal Ns function test
    ${json_value}=     json_from_file      ${heal_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_url}/${nsInstId}/heal    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${jobInstId}=    Convert To String      ${response_json['jobId']}
    Set Global Variable     ${jobInstId}

GetJobTest
    [Documentation]    Query Ns Job function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_job_url}/${jobInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

UpdateNSTest
    [Documentation]    Scale Ns function test
    ${json_value}=     json_from_file      ${update_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_url}/${nsInstId}/update    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateNSTest
    [Documentation]    Terminate Ns function test
    ${json_value}=     json_from_file      ${terminate_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_url}/${nsInstId}/terminate    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

DeleteNSTest
    [Documentation]    Delete NS function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    Delete Request    web_session     ${ns_url}/${nsInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmHealthCheckTest
    [Documentation]    check health for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active

LcmGetNsTest
    [Documentation]    get ns instances for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${ns_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

QueryAllPnfsTest
    [Documentation]    Query all pnfs function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${pnfs_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CreateNSInstanceTest
    [Documentation]    Create NS Instance function test
    ${json_value}=     json_from_file      ${create_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json    globalcustomerid=global-customer-id-test1    servicetype=service-type-test1
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstanceId}=    Convert To String      ${response_json['nsInstanceId']}
    Set Global Variable     ${nsInstanceId}

QueryNSInstancesTest
    [Documentation]    Query Ns Instances function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${ns_instances_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

UpdateNSInstanceTest
    [Documentation]    Scale Ns Instance function test
    ${json_value}=     json_from_file      ${update_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    Log    ${json_string}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}/${nsInstId}/update    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateNSInstanceTest
    [Documentation]    Terminate Ns Instance function test
    ${json_value}=     json_from_file      ${terminate_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}/${nsInstanceId}/terminate    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmCreateSubscriptionsTest
    [Documentation]    Postdeal Ns function test
    ${json_value}=     json_from_file      ${create_subscriptions_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${get_subscriptions_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmGetSubscriptionsTest
    [Documentation]    get subscriptions for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_subscriptions_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}