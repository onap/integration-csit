*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP   

*** Variables ***
@{return_ok_list}=   200  201  202  204
${queryswagger_url}    /api/nslcm/v1/swagger.json
${create_ns_url}       /api/nslcm/v1/ns
${delete_ns_url}       /api/nslcm/v1/ns
${get_ns_url}          /api/nslcm/v1/ns
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
${instantiate_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/instantiate_ns.json
${postdeal_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/postdeal_ns.json
${scale_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/scale_ns.json
${update_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/update_ns.json
${terminate_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_ns.json
${update_job_ns_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/update_job_ns.json
${create_vnf_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_vnf.json
${terminate_vnf_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_vnf.json
${create_vl_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_vl.json
${create_sfcs_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_sfc.json
${create_subscriptions_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_subscription.json
${create_pnfs_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_pnf.json

${create_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/create_ns_instance.json
${heal_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/heal_ns_instance.json
${instantiate_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/instantiate_ns_instance.json
${postdeal_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/postdeal_ns_instance.json
${scale_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/scale_ns_instance.json
${update_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/update_ns_instance.json
${terminate_ns_instance_json}    ${SCRIPTS}/../tests/vfc/nfvo-lcm/jsoninput/terminate_ns_instance.json

#global variables
${nsInstId}
${jobInstId}
${vnfInstId}
${vlInstId}
${sfcInstId}
${pnfId}
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
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
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
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstId}=    Convert To String      ${response_json['nsInstanceId']}
    Set Global Variable     ${nsInstId}
    
CreateSfcTest
    [Documentation]    Create sfc function test
    ${json_value}=     json_from_file      ${create_sfcs_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${sfcs_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${sfcInstId}=    Convert To String      ${response_json['sfcInstId']}
    Set Global Variable     ${sfcInstId}
    
QuerySfcTest
    [Documentation]    Query sfc function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${sfcs_url}/${sfcInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
DeleteSfcTest
    [Documentation]    Delete sfc function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=    Delete Request    web_session     ${sfcs_url}/${sfcInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
CreateVnfsTest
    [Documentation]    Create vnfs function test
    ${json_value}=     json_from_file      ${create_vnf_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
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
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${vnfs_url}/${vnfInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
TerminateVnfTest
    [Documentation]    Terminate vnf function test
	${json_value}=     json_from_file      ${terminate_vnf_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${terminate_vnfs_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

CreateVlsTest
    [Documentation]    Create vl function test
    ${json_value}=     json_from_file      ${create_vl_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${vls_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vlInstId}=    Convert To String      ${response_json['vlId']}
    Set Global Variable     ${vlInstId}
    
QueryVlTest
    [Documentation]    Query vl function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${vls_url}/${vlInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
DeleteVlTest
    [Documentation]    Delete vl function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=    Delete Request    web_session     ${vls_url}/${vlInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
        
InstantiateNSTest
    [Documentation]    Instantiate Ns function test
    ${json_value}=     json_from_file      ${instantiate_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/instantiate    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
	
QueryNSTest
    [Documentation]    Query Ns function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_ns_url}/${nsInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
        
ScaleNSTest
    [Documentation]    Scale Ns function test
    ${json_value}=     json_from_file      ${scale_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/scale    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
	
HealNSTest
    [Documentation]    Heal Ns function test
    ${json_value}=     json_from_file      ${heal_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/heal    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${jobInstId}=    Convert To String      ${response_json['jobId']}
    Set Global Variable     ${jobInstId}
    
UpdateJobTest
    [Documentation]    Update Ns Job function test
	${json_value}=     json_from_file      ${update_job_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${get_job_url}/${jobInstId}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    
GetJobTest
    [Documentation]    Query Ns Job function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_job_url}/${jobInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
PostdealNSTest
    [Documentation]    Postdeal Ns function test
    ${json_value}=     json_from_file      ${postdeal_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/postdeal    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
UpdateNSTest
    [Documentation]    Scale Ns function test
    ${json_value}=     json_from_file      ${update_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    Log    ${json_string}    
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/update    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
TerminateNSTest
    [Documentation]    Terminate Ns function test
    ${json_value}=     json_from_file      ${terminate_ns_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_ns_url}/${nsInstId}/terminate    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

DeleteNS Test
    [Documentation]    Delete NS function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=    Delete Request    web_session     ${delete_ns_url}/${nsInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmHealthCheckTest
    [Documentation]    check health for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${healthcheck_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${health_status}=    Convert To String      ${response_json['status']}
    Should Be Equal    ${health_status}    active

LcmGetNsTest
    [Documentation]    get ns instances for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_ns_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
CreatePnfsTest
    [Documentation]    Create pnf function test
    ${json_value}=     json_from_file      ${create_pnfs_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${pnfs_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${pnfId}=    Convert To String      ${response_json['pnfId']}
    Set Global Variable     ${pnfId}
    
QueryAllPnfsTest
    [Documentation]    Query all pnfs function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${pnfs_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
QueryPnfsTest
    [Documentation]    Query pnf function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${pnfs_url}/${pnfId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
DeletePnfTest
    [Documentation]    Delete pnf function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=    Delete Request    web_session     ${pnfs_url}/${pnfId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
CreateNSInstanceTest
    [Documentation]    Create NS Instance function test
    ${json_value}=     json_from_file      ${create_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${nsInstanceId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${nsInstanceId}
    
QueryNSInstancesTest
    [Documentation]    Query Ns Instances function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${ns_instances_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
QueryNSIntanceTest
    [Documentation]    Query One Ns Instance function test
	${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${ns_instances_url}/${nsInstanceId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
InstantiateNSInstanceTest
    [Documentation]    Instantiate Ns function test
    ${json_value}=     json_from_file      ${instantiate_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}/${nsInstanceId}/instantiate    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
        
ScaleNSInstanceTest
    [Documentation]    Scale Ns Instance function test
    ${json_value}=     json_from_file      ${scale_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}/${nsInstanceId}/scale    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
	
HealNSTest
    [Documentation]    Heal Ns function test
    ${json_value}=     json_from_file      ${heal_ns_instance_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_instances_url}/${nsInstanceId}/heal    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    
LcmCreateSubscriptionsTest
    [Documentation]    Postdeal Ns function test
    ${json_value}=     json_from_file      ${create_subscriptions_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${get_subscriptions_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}

LcmGetSubscriptionsTest
    [Documentation]    get subscriptions for nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_subscriptions_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}