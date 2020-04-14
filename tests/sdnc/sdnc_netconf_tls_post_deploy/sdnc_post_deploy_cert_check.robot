*** Settings ***

Documentation     SDNC, Netconf-Pnp-Simulator E2E Test Case Scenarios

Library 	      RequestsLibrary
Resource          ./resources/sdnc-keywords.robot

Suite Setup       Create sessions

*** Test Cases ***

Health Check AAF CertService
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Service is Up and Running
    Run health check

Reload AAF CertService Configuration
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Configuration is Reloaded
    Send Get Request And Validate Response  /reload  200

Check AAF CertService Container Is Ready
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Send Request to /ready Endpoint and Expect 200
    Send Get Request And Validate Response  /ready  200

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

#Check AAF-CertService Successfully Creates Certificates for SDNC
    #[Tags]      AAF-CERT-SERVICE-SDNC
    #[Documentation]  Run with SDNC CSR and Expected Exit Code 0
    #Run Cert Service Client And Validate JKS File Creation And Client Exit Code  ${SDNC_CSR_FILE}  ${SDNC_CONTAINER_NAME}  0

#Check SDNC-ODL Certificates Installation In Keystore And Truststore
    #[Tags]      SDNC-ODL-CERTIFICATE-KEYSTORE-VALIDATE
    #[Documentation]  Validate Certificates Got Installed in SDNC-ODL Keystore
    #Send Get Request And Validate Response Sdnc  ${SDNC_KEYSTORE_CONFIG_PATH}  200

#Check AAF-CertService Successfully Creates Certificates for Netconf-Pnp-Simulator
    #[Tags]      AAF-CERT-SERVICE-NETCONF_PNP_SIMULATOR
    #[Documentation]  Run with NETCONF-PNP-SIMULATOR CSR and Expect Exit Code 0
    #Run Cert Service Client And Validate JKS File Creation And Client Exit Code  ${NETCONF_PNP_SIM_CSR_FILE}  ${NETCONF_PNP_SIM_CONTAINER_NAME}  0

Configure SDNC-ODL Netconf-Pnp-Simulatore TLS Connection
    [Tags]      SDNC-ODL-NETCONF-PNP_SIMULATION-TLS-CONNECTION-CONFIG
    [Documentation]  Config SDNC-ODL and Netconf-Pnp-Simulation TLS Connection
    Configure TLS Connection  ${SDNC_CONTAINER_NAME}  ${NETCONF_PNP_SIM_CONTAINER_NAME}

Check SDNC-ODL Netconf-Pnp-Simulatore TLS Connection Establishment
    [Tags]      SDNC-ODL-NETCONF-PNP_SIMULATION-TLS-CONNECTION
    [Documentation]  Validate SDNC-ODL and Netconf-Pnp-Simulation TLS Connection Establishment
    Send Get Request And Validate TLS Connection Response  ${SDNC_MOUNT_PATH}  200