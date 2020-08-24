*** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library	          robot_library.DcaeLibrary
Library           robot_library.DmaapLibrary
Library           robot_library.CertsLibrary
Library 	      RequestsLibrary
Library           OperatingSystem
Library           Collections
Variables         ./robot_library/DcaeVariables.py
Resource          ../../../common.robot
Resource          ./dcae_properties.robot

*** Keywords ***
Create sessions
    [Documentation]  Create all required sessions
    ${auth}=  Create List  ${VESC_HTTPS_USER}   ${VESC_HTTPS_PD}
    ${wrong_auth}=  Create List  ${VESC_HTTPS_WRONG_USER}  ${VESC_HTTPS_WRONG_PD}
    ${certs}=  Create List  ${VESC_CERT}  ${VESC_KEY}
    ${wrong_certs}=  Create List  ${VESC_WRONG_CERT}  ${VESC_WRONG_KEY}
    ${outdated_certs}=  Create List  ${VESC_OUTDATED_CERT}  ${VESC_OUTDATED_KEY}
    Create Session    dcae_vesc_url    ${VESC_URL}
    Set Global Variable    ${http_session}    dcae_vesc_url
    Create Session    dcae_vesc_url_https    ${VESC_URL_HTTPS}  auth=${auth}  disable_warnings=1
    Set Global Variable    ${https_basic_auth_session}    dcae_vesc_url_https
    Create Session  dcae_vesc_url_https_wrong_auth  ${VESC_URL_HTTPS}  auth=${wrong_auth}  disable_warnings=1
    Set Global Variable  ${https_wrong_auth_session}  dcae_vesc_url_https_wrong_auth
    Create Client Cert Session  dcae_vesc_url_https_cert  ${VESC_URL_HTTPS}  client_certs=${certs}  disable_warnings=1
    Set Global Variable  ${https_valid_cert_session}  dcae_vesc_url_https_cert
    Create Client Cert Session  dcae_vesc_url_https_wrong_cert  ${VESC_URL_HTTPS}  client_certs=${wrong_certs}  disable_warnings=1  verify=${False}
    Set Global Variable  ${https_invalid_cert_session}  dcae_vesc_url_https_wrong_cert
    Create Client Cert Session  dcae_vesc_url_https_outdated_cert  ${VESC_URL_HTTPS}  client_certs=${outdated_certs}  disable_warnings=1  verify=${False}
    Set Global Variable  ${https_outdated_cert_session}  dcae_vesc_url_https_outdated_cert
    Create Session  dcae_vesc_url_https_wo_auth  ${VESC_URL_HTTPS}  disable_warnings=1
    Set Global Variable  ${https_no_cert_no_auth_session}  dcae_vesc_url_https_wo_auth

Create header
    ${headers}=    Create Dictionary    Content-Type=application/json
    Set Global Variable    ${suite_headers}    ${headers}

Get DCAE Nodes
    [Documentation]    Get DCAE Nodes from Consul Catalog
    ${session}=    Create Session 	dcae 	${GLOBAL_DCAE_CONSUL_URL}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json  X-Consul-Token=abcd1234  X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	dcae 	/v1/catalog/nodes        headers=${headers}
    Log    Received response from dcae consul: ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${NodeList}=   Get Json Value List   ${resp.text}   Node
    ${NodeListLength}=  Get Length  ${NodeList}
    ${len}=  Get Length   ${NodeList}
    Should Not Be Equal As Integers   ${len}   0
    [Return]    ${NodeList}

DCAE Node Health Check
    [Documentation]    Perform DCAE Node Health Check
    [Arguments]    ${NodeName}
    ${session}=    Create Session 	dcae-${NodeName} 	${GLOBAL_DCAE_CONSUL_URL}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json  X-Consul-Token=abcd1234  X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${hcpath}=   Catenate  SEPARATOR=    /v1/health/node/    ${NodeName}
    ${resp}= 	Get Request 	dcae-${NodeName} 	${hcpath}        headers=${headers}
    Log    Received response from dcae consul: ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${StatusList}=  Get Json Value List   ${resp.text}    Status
    ${len}=  Get Length  ${StatusList}
    Should Not Be Equal As Integers   ${len}   0
    DCAE Check Health Status    ${NodeName}   ${StatusList[0]}    Serf Health Status

DCAE Check Health Status
    [Arguments]    ${NodeName}    ${ItemStatus}   ${CheckType}
    Should Be Equal As Strings    ${ItemStatus}    passing
    Log   Node: ${NodeName} ${CheckType} check pass ok

VES Collector Suite Setup DMaaP
    [Documentation]   Start DMaaP Mockup Server
    ${ret}=  Setup DMaaP Server
    Should Be Equal As Strings     ${ret}    true

VES Collector Suite Shutdown DMaaP
    [Documentation]   Shutdown DMaaP Mockup Server
    ${ret}=  Shutdown DMaap
    Should Be Equal As Strings     ${ret}    true

Check DCAE Results
    [Documentation]    Parse DCAE JSON response and make sure all rows have healthTestStatus=GREEN
    [Arguments]    ${json}
    @{rows}=    Get From Dictionary    ${json['returns']}    rows
    @{headers}=    Get From Dictionary    ${json['returns']}    columns
    # Retrieve column names from headers
    ${columns}=    Create List
    :for    ${header}    IN    @{headers}
    \    ${colName}=    Get From Dictionary    ${header}    colName
    \    Append To List    ${columns}    ${colName}
    # Process each row making sure status=GREEN
    :for    ${row}    IN    @{rows}
    \    ${cells}=    Get From Dictionary    ${row}    cells
    \    ${dict}=    Make A Dictionary    ${cells}    ${columns}
    \    Dictionary Should Contain Item    ${dict}    healthTestStatus    GREEN

Make A Dictionary
    [Documentation]    Given a list of column names and a list of dictionaries, map columname=value
    [Arguments]     ${columns}    ${names}    ${valuename}=value
    ${dict}=    Create Dictionary
    ${collength}=    Get Length    ${columns}
    ${namelength}=    Get Length    ${names}
    :for    ${index}    IN RANGE    0   ${collength}
    \    ${name}=    Evaluate     ${names}[${index}]
    \    ${valued}=    Evaluate     ${columns}[${index}]
    \    ${value}=    Get From Dictionary    ${valued}    ${valueName}
    \    Set To Dictionary    ${dict}   ${name}    ${value}
    [Return]     ${dict}

Json String To Dictionary
    [Arguments]  ${json_string}
    ${json_dict}=  evaluate    json.loads('''${json_string}''')    json
    [Return]   ${json_dict}

Dictionary To Json String
    [Arguments]  ${json_dict}
    ${json_string}=    evaluate    json.dumps(${json_dict})    json
    [Return]    ${json_string}

Get DCAE Service Component Status
    [Documentation]   Get the status of a DCAE Service Component
    [Arguments]    ${url}    ${urlpath}     ${usr}    ${passwd}
    ${auth}=  Create List  ${usr}  ${passwd}
    ${session}=    Create Session 	dcae-service-component 	${url}    auth=${auth}
    ${resp}= 	Get Request 	dcae-service-component 	${urlpath}
    [Return]    ${resp}

Publish Event To VES Collector
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${session}  ${evtpath}   ${evtdata}
    ${resp}= 	Post Request 	${session}  	${evtpath}     data=${evtdata}   headers=${suite_headers}
    [Return] 	${resp}

Publish Event To VES Collector With Put Method
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${session}  ${evtpath}   ${evtdata}
    ${resp}= 	Put Request 	${session}  	${evtpath}     data=${evtdata}   headers=${suite_headers}
    [Return] 	${resp}

Send Request And Validate Response And Error Message
    [Documentation]  Post single event to passed url and validate received response code and content
    [Arguments]  ${keyword}  ${session}  ${evtpath}  ${evtjson}  ${resp_code}  ${msg_content}
    ${resp}=  Send Request And Validate Response  ${keyword}  ${session}  ${evtpath}  ${evtjson}  ${resp_code}
    ${error_message}=  Set Variable  ${resp.json()['requestError']['ServiceException']['text']}
    Should Be Equal As Strings  ${msg_content}  ${error_message}

Send Request And Validate Response
    [Documentation]  Post single event to passed url with passed data and validate received response
    [Arguments]  ${keyword}  ${session}  ${evtpath}  ${evtjson}  ${resp_code}  ${msg_code}=None  ${topic}=None
    ${evtdata}=  Get Data From File  ${evtjson}
    ${resp}=  Run Keyword  ${keyword}  ${session}  ${evtpath}  ${evtdata}
    Log    Receive HTTPS Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    Run Keyword If  '${msg_code}' != 'None'  Check Whether Message Received  ${msg_code}  ${topic}
    [Return]  ${resp}

Check Whether Message Received
    [Documentation]  Validate if message has been received
    [Arguments]  ${msg_code}  ${topic}
    ${ret}=  Run Keyword If  '${topic}' != 'None'  DMaaP Message Receive On Topic  ${msg_code}  ${topic}
    ...  ELSE  DMaaP Message Receive  ${msg_code}
    Should Be Equal As Strings    ${ret}    true

Send Request And Expect Error
    [Documentation]  Post singel event to passed url with passed data and expect error
    [Arguments]  ${keyword}  ${session}  ${evtpath}  ${evtjson}  ${error_type}  @{error_content}
    ${evtdata}=  Get Data From File  ${evtjson}
    ${err_msg}=  Run Keyword And Expect Error  ${error_type}  ${keyword}  ${session}  ${evtpath}  ${evtdata}
    FOR    ${content}    IN    @{error_content}
           Should Contain   ${err_msg}  ${content}
    END
    Log  Recieved error message ${err_msg}

Run Healthcheck
    [Documentation]  Run Healthcheck
    [Arguments]  ${session}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	${session} 	/healthcheck        headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200
