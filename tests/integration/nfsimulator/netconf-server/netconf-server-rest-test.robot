*** Settings ***
Documentation     Run healthcheck
Library 	      RequestsLibrary
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


