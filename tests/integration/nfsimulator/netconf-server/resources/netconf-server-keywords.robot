*** Settings ***
Library 	      RequestsLibrary
Resource          ../../../../common.robot
Resource          ./netconf-server-properties.robot

*** Keywords ***

Run Healthcheck
    [Documentation]  Run Healthcheck
    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /healthcheck
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.text}  UP

Run Readiness
    [Documentation]  Run Readiness
    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /readiness
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.text}  Ready

Update NetConf Module Configuration
    [Arguments]   ${module}  ${path_to_data}  ${resp_code}
    ${data}=  Get Data From File  ${path_to_data}

    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=    POST On Session    netconf_server_session    /change_config/${module}   data=${data}
    Should Be Equal As Strings    ${resp.status_code}    ${resp_code}

Fetch NetConf Module Change Configuration History
    [Arguments]   ${resp_code}

    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=    GET On Session    netconf_server_session    /change_history
    Should Be Equal As Strings    ${resp.status_code}    ${resp_code}
    Log  ${resp.json()}
    Should Not Be Empty  ${resp.json()}
