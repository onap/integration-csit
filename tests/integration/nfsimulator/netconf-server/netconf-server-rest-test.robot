*** Settings ***
Documentation     Run healthcheck
Library 	      RequestsLibrary
Library           Collections
Resource          ./resources/netconf-server-keywords.robot


*** Test Cases ***

Netconf Server Healthy Check
    [Tags]      Netconf-Server
    [Documentation]   Server Should be healthy
    Verify That Server Is Healthy

Netconf Server Readiness Check
    [Tags]      Netconf-Server
    [Documentation]   Server Should be ready
    Verify That Server Is Ready

Netconf Module Configuration Update
    [Tags]      Netconf-Server
    [Documentation]   Update Should Be Distributed
    Update NetConf Module Configuration  pnf-simulator  ${PNF_SIMULATOR_DATA_XML}  202
    Sleep   20s     Wait for message distribution in Kafka
    Verify That Change Is Available In NetConf Module Change Configuration History  200

Netconf Module Configuration History Get
    [Tags]      Netconf-Server
    [Documentation]   Configuration History should be returned
    Update NetConf Module Configuration  pnf-simulator  ${PNF_SIMULATOR_DATA_XML}  202
    Verify That Configuration History Is Available  200