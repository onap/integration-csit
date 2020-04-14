*** Settings ***

Documentation     SDNC E2E Test Case Scenarios
Suite Setup       Create sessions
Library 	      RequestsLibrary
Resource          ./resources/sdnc-keywords.robot


*** Test Cases ***

Test SDNC Keystore
     [Documentation]    Checking keystore after SDNC installation
     Create Session    sdnc  http://localhost:8282/restconf
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
     ${resp}=    Get Request    sdnc    ${SDNC_KEYSTORE_CONFIG_PATH}    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${keystoreContent}=    Convert To String    ${resp.content}
     Log to console  *************************
     Log to console  ${resp.content}
     Log to console  *************************

Test SDNC PNF Mount
     [Documentation]    Checking PNF mount after SDNC installation
     Create Session   sdnc  http://localhost:8282/restconf
     ${mount}=    Get File    ${REQUEST_DATA_PATH}${/}mount.xml
     Log to console  ${mount}
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
     ${resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}    201
     Sleep  30
     &{headers1}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
     ${resp1}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers1}
     Should Be Equal As Strings    ${resp1.status_code}    200
     Log to console  ${resp1.content}
     Should Contain  ${resp1.content}     netconf-id
     Should Contain  ${resp1.content}     netconf-param

Test SDNC Delete PNF Mount
     [Documentation]    Checking PNF mount Delete from SDNC
     Create Session   sdnc  http://localhost:8282/restconf
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
     ${deleteresponse}=    Delete Request    sdnc    ${SDNC_MOUNT_PATH}    headers=${headers}
     Should Be Equal As Strings    ${deleteresponse.status_code}    200
     Sleep  30
     ${deleteresponse1}=    Delete Request    sdnc    ${SDNC_KEYSTORE_CONFIG_PATH}
     Should Be Equal As Strings    ${deleteresponse1.status_code}    200

Health Check AAF CertService
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Service is up and running
    Run health check

Reload AAF CertService Configuration
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Configuration was changed
    Send Get Request And Validate Response  /reload  200

Check AAF CertService Application is Ready
    [Tags]      AAF-CERT-SERVICE
    [Documentation]   Send request to /ready endpoint and expect 200
    Send Get Request And Validate Response  /ready  200

Check AAF CertService Client Successfully Creates Keystore and Truststore for SDNC
    [Tags]      AAF-CERT-SERVICE-SDNC
    [Documentation]  Run with SDNC CSR and expected exit code 0
    Run Cert Service Client And Validate SDNC JKS File Creation And Client Exit Code  ${SDNC_CSR_FILE}  0

Check SDNC-ODL Certificate Installation in Keystore
    [Tags]      SDNC-ODL-CERTIFICATE-KEYSTORE-VALIDATE
    [Documentation]  Validate Certificates got Installed in SDNC-ODL Keystore
    Test SDNC Keystore

Check AAF CertService Client Successfully Creates Keystore and Truststore for Netconf-pnp-simulator
    [Tags]      AAF-CERT-SERVICE-NETCONF_PNP_SIMULATOR
    [Documentation]  Run with NETCONF-PNP-SIMULATOR CSR and expected exit code 0
    Run Cert Service Client And Validate Netconf-pnp-simulator JKS File Creation And Client Exit Code  ${NETCONF_PNP_SIM_CSR_FILE}  0

Check SDNC-ODL Netconf-Pnp-Simulatore TLS Connection Establishment
    [Tags]      SDNC-ODL-NETCONF-PNP_SIMULATION-TLS-CONNECTION
    [Documentation]  Validate SDNC-ODL and Netconf-Pnp-Simulation TLS Connection Establishment
    Test SDNC NETCONF_PNP_SIMULATOR TLS Mount