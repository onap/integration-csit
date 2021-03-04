*** Settings ***

Documentation     SDNC, Netconf-Pnp-Simulator E2E Test Case Scenarios

Library 	      RequestsLibrary
Resource          ./resources/sdnc-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

Check SDNC Keystore For Netopeer2 Certificates
    [Tags]      SDNC-NETOPEER2-CERT-DEPLOYMENT
    [Documentation]    Checking Keystore after SDNC istallation
    Send Get Request And Validate Response Sdnc  ${SDNC_KEYSTORE_CONFIG_PATH}  200


Check SDNC And PNF TLS Connection Over Netopeer2 Certificates
    [Tags]      SDNC-PNF-TLS-CONNECTION-CHECK
   [Documentation]    Checking PNF Mount after SDNC Installation
    Send Get Request And Validate TLS Connection Response  ${SDNC_MOUNT_PATH}  200

Check PNF Delete And Remove Netopeer2 Certificates From Keystore
    [Tags]      SDNC-PNF-MOUNT-DELETE-CLEAR-KEYSTORE
    [Documentation]    Checking PNF Mount Delete from SDNC
   Send Delete Request And Validate PNF Mount Deleted  ${SDNC_MOUNT_PATH}  200

