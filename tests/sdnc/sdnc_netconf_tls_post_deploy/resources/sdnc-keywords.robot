*** Settings ***

Resource          ../../../common.robot
Resource          ./sdnc-properties.robot
Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           Collections
Library           ../libraries/ClientManager.py  ${MOUNT_PATH}

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    Create Session    aaf_cert_service_url    ${AAFCERT_URL}
    Set Suite Variable    ${http_session}    aaf_cert_service_url

Run Healthcheck
    [Documentation]  Run Healthcheck
    ${resp}= 	Get Request 	${http_session} 	/actuator/health
    Should Be Equal As Strings 	${resp.status_code} 	200
    Validate Recieved Response  ${resp}  status  UP

Validate Recieved Response
    [Documentation]  Validare message that has been received
    [Arguments]  ${resp}  ${key}  ${expected_value}
    ${json}=    Parse Json      ${resp.content}
    ${value}=  Get From Dictionary  ${json}  ${key}
    Should Be Equal As Strings    ${value}    ${expected_value}

Send Get Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    ${resp}= 	Get Request 	${http_session}    ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Run Cert Service Client And Validate SDNC JKS File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code For SDNC
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass
    ${install_certs}=  Can Install Keystore And Truststore Certs  ${CONF_SCRIPT}  ${SDNC_CONTAINER_NAME}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by Passphrase
    Should Be True  ${install_certs}  Cannot Install Keystore/Truststore

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

Run Cert Service Client And Validate Netconf-pnp-simulator JKS File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code for Netconf-pnp-simulator
    [Arguments]   ${env_file}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass
    ${install_certs}=  Can Install Keystore And Truststore Certs  ${CONF_SCRIPT}  ${NETCONF_PNP_SIM_CONTAINER_NAME}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by Passphrase
    Should Be True  ${install_certs}  Cannot Install Keystore/Truststore

Test SDNC NETCONF_PNP_SIMULATOR TLS Mount
     [Documentation]    Checking PNP-Simulation mount after SDNC installation
     Create Session   sdnc  http://localhost:8282/restconf
     ${mount}=    Get File     ${REQUEST_DATA_PATH}${/}mount.xml
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