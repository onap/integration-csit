*** Settings ***
Library           RequestsLibrary
Resource          ../../../../common.robot
Resource          ./netconf-server-properties.robot

*** Keywords ***

Verify That Server Is Healthy
    [Documentation]  Verify that server is healthy
    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /healthcheck
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.text}  UP

Verify That Server Is Ready
    [Documentation]  Verify that server is ready
    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /readiness
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.text}  Ready

Update NetConf Module Configuration
    [Documentation]  Update module configuration
    [Arguments]   ${module}  ${path_to_data}  ${resp_code}
    ${data}=  Get Data From File  ${path_to_data}

    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=    POST On Session    netconf_server_session    /change_config/${module}   data=${data}
    Should Be Equal As Strings    ${resp.status_code}    ${resp_code}

Verify That Change Is Available In NetConf Module Change Configuration History
    [Documentation]  Verify that configuration was distributed to Kafka
    [Arguments]   ${resp_code}

    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=    GET On Session    netconf_server_session    /change_history
    Should Be Equal As Strings    ${resp.status_code}    ${resp_code}
    ${actual_data}=  Convert To String  ${resp.json()}
    Should Be Equal  ${actual_data}  [{u'new': {u'path': u'/pnf-simulator:config/itemValue1', u'value': 42}, u'type': u'ChangeCreated'}, {u'new': {u'path': u'/pnf-simulator:config/itemValue2', u'value': 35}, u'type': u'ChangeCreated'}]

Get NetConf Module Configuration
    [Documentation]  Get module configuration
    [Arguments]   ${resp_code}

    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /get_config/pnf-simulator
    Should Be Equal As Strings    ${resp.status_code}    ${resp_code}
    Dictionary Should Contain Item   ${resp.json()['config']}  itemValue1  ${42}
    Dictionary Should Contain Item   ${resp.json()['config']}  itemValue2  ${35}
