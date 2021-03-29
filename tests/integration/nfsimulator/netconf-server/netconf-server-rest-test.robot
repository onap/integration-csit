*** Settings ***
Documentation     Run healthcheck
Library 	      RequestsLibrary
Resource          ./resources/netconf-server-keywords.robot


*** Test Cases ***

Netconf Server Rest API Health Check
    [Tags]      Netconf-Server
    [Documentation]   Run healthcheck
    Run Healthcheck

Netconf Server Rest API Readiness Check
    [Tags]      Netconf-Server
    [Documentation]   Run readiness
    Run Readiness 