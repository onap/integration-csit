*** Settings ***
Library 	      RequestsLibrary
Resource          ./netconf-server-properties.robot

*** Keywords ***

Run Healthcheck
    [Documentation]  Run Healthcheck
    Create Session    netconf_server_session    ${NETCONF_SERVER_URL}
    ${resp}=  GET On Session  netconf_server_session  /healthcheck
    Should Be Equal As Strings 	${resp.status_code}  200
    Should Be Equal As Strings  ${resp.text}  UP
