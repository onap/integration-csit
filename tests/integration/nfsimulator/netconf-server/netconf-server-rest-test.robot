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

Netconf Module Configuration Update
    [Tags]      Netconf-Server
    [Documentation]   Should Be Distributed To Kafka
    Update NetConf Module Configuration  pnf-simulator  ${PNF_SIMULATOR_DATA_XML}  202
    Sleep   20s     Wait for message distribution in Kafka
    Fetch NetConf Module Change Configuration History  200


