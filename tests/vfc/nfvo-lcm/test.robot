*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
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
    ${resp}=   GET On Session    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

NslcmSwaggerByMSBTest
    [Documentation]    query swagger info of nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

CreateNSTest
    [Documentation]    Create NS function test
    ${data}=    Get Binary File     ${create_ns_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_url}   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstId}=    Convert To String      ${response_json['nsInstanceId']}
    Set Global Variable     ${nsInstId}

CreateVnfTest
    [Documentation]    Create vnf function test
    ${data}=    Get Binary File     ${create_vnf_json}
    ${json_value}=    Evaluate    json.loads(r'''${data}''', strict=False)    json
    Set To Dictionary    ${json_value}    nsInstanceId=${nsInstId}
    ${json_string}=     Evaluate    json.dumps(${json_value})    json
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${vnfs_url}   data=${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vnfInstId}=    Convert To String      ${response_json['vnfInstId']}
    Set Global Variable     ${vnfInstId}

QueryVnfTest
    [Documentation]    Query vnf function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${vnfs_url}/${vnfInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateVnfTest
    [Documentation]    Terminate vnf function test
    ${data}=    Get Binary File     ${terminate_vnf_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${terminate_vnfs_url}/${vnfInstId}   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CreateVlTest
    [Documentation]    Create vl function test
    ${data}=    Get Binary File     ${create_vl_json}
    ${json_value}=    Evaluate    json.loads(r'''${data}''', strict=False)    json
    Set To Dictionary    ${json_value}    nsInstanceId=${nsInstId}
    ${json_string}=     Evaluate    json.dumps(${json_value})    json
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${vls_url}   data=${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vlInstId}=    Convert To String      ${response_json['vlId']}
    Set Global Variable     ${vlInstId}

DeleteVlTest
    [Documentation]    Delete vl function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    Delete On Session    web_session    ${vls_url}/${vlInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

ScaleNSTest
    [Documentation]    Scale Ns function test
    ${data}=    Get Binary File     ${scale_ns_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_url}/${nsInstId}/scale   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

HealNSTest
    [Documentation]    Heal Ns function test
    ${data}=    Get Binary File     ${heal_ns_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_url}/${nsInstId}/heal   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${jobInstId}=    Convert To String      ${response_json['jobId']}
    Set Global Variable     ${jobInstId}

GetJobTest
    [Documentation]    Query Ns Job function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${get_job_url}/${jobInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

UpdateNSTest
    [Documentation]    Scale Ns function test
    ${data}=    Get Binary File     ${update_ns_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_url}/${nsInstId}/update   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateNSTest
    [Documentation]    Terminate Ns function test
    ${data}=    Get Binary File     ${terminate_ns_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_url}/${nsInstId}/terminate   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

DeleteNSTest
    [Documentation]    Delete NS function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    Delete On Session    web_session    ${ns_url}/${nsInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmHealthCheckTest
    [Documentation]    check health for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active

LcmGetNsTest
    [Documentation]    get ns instances for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${ns_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

QueryAllPnfsTest
    [Documentation]    Query all pnfs function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${pnfs_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CreateNSInstanceTest
    [Documentation]    Create NS Instance function test
    ${data}=    Get Binary File     ${create_ns_instance_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json    globalcustomerid=global-customer-id-test1    servicetype=service-type-test1
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_instances_url}   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstanceId}=    Convert To String      ${response_json['nsInstanceId']}
    Set Global Variable     ${nsInstanceId}

QueryNSInstancesTest
    [Documentation]    Query Ns Instances function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${ns_instances_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

UpdateNSInstanceTest
    [Documentation]    Scale Ns Instance function test
    ${data}=    Get Binary File     ${update_ns_instance_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_instances_url}/${nsInstId}/update   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

TerminateNSInstanceTest
    [Documentation]    Terminate Ns Instance function test
    ${data}=    Get Binary File     ${terminate_ns_instance_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${ns_instances_url}/${nsInstanceId}/terminate   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmCreateSubscriptionsTest
    [Documentation]    Postdeal Ns function test
    ${data}=    Get Binary File     ${create_subscriptions_json}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=    POST On Session    web_session    ${get_subscriptions_url}   data=${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmGetSubscriptionsTest
    [Documentation]    get subscriptions for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=   GET On Session    web_session    ${get_subscriptions_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}