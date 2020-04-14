*** Settings ***

Resource          ../../../common.robot
Resource          ./sdnc-properties.robot

Library           Collections
Library 	      RequestsLibrary
Library           HttpLibrary.HTTP
Library           ../libraries/ClientManager.py  ${MOUNT_PATH}  ${TRUSTSTORE_PATH}

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    ${certs}=  Create List  ${CERTSERVICE_SERVER_CRT}  ${CERTSERVICE_SERVER_KEY}
    Create Client Cert Session  alias  ${AAFCERT_URL}  client_certs=${certs}  verify=${ROOTCA}  disable_warnings=1
    Set Suite Variable  ${https_valid_cert_session}  alias

Run Healthcheck
    [Documentation]  Run Healthcheck
    ${resp}=  Get Request 	${https_valid_cert_session} 	/actuator/health
    Should Be Equal As Strings 	${resp.status_code} 	200
    Validate Recieved Response  ${resp}  status  UP

Validate Recieved Response
    [Documentation]  Validate message that has been received
    [Arguments]  ${resp}  ${key}  ${expected_value}
    ${json}=    Parse Json      ${resp.content}
    ${value}=  Get From Dictionary  ${json}  ${key}
    Should Be Equal As Strings    ${value}    ${expected_value}

Send Get Request And Validate Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    ${resp}= 	Get Request 	${https_valid_cert_session}  ${path}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Get Request And Validate Response Sdnc
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    Create Session   sdnc_restconf  ${SDNC_RESTCONF_URL}
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}= 	Get Request    sdnc_restconf    ${path}    headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	${resp_code}

Send Get Request And Validate TLS Connection Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    Create Session   sdnc_restconf  ${SDNC_RESTCONF_URL}
    ${mount}=    Get File    ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
    ${resp}=    Put Request    sdnc_restconf    ${path}    data=${mount}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    201
    Sleep  30
    &{headers1}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp1}=    Get Request    sdnc_restconf    ${PNFSIM_MOUNT_PATH}    headers=${headers1}
    Should Be Equal As Strings    ${resp1.status_code}    ${resp_code}
    Should Contain  ${resp1.content}     netconf-id
    Should Contain  ${resp1.content}     netconf-param

Send Delete Request And Validate PNF Mount Deleted
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    Create Session   sdnc_restconf  ${SDNC_RESTCONF_URL}
    ${mount}=    Get File    ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${deleteresponse}=    Delete Request    sdnc_restconf    ${path}    data=${mount}    headers=${headers}
    Should Be Equal As Strings 	${deleteresponse.status_code} 	${resp_code}
    Sleep  30
    ${del_topology}=    Delete Request    sdnc_restconf    ${SDNC_NETWORK_TOPOLOGY}
    ${del_keystore}=    Delete Request    sdnc_restconf    ${SDNC_KEYSTORE_CONFIG_PATH}
    Should Be Equal As Strings    ${del_keystore.status_code}    ${resp_code}
    Should Be Equal As Strings    ${del_topology.status_code}    ${resp_code}

Configure TLS Connection
    [Documentation]   Configure TLS Connection]
    [Arguments]   ${SDNC_CONTAINER_NAME}  ${NETCONF_PNP_SIM_CONTAINER_NAME}
    ${exit_code}=  configure_tls  ${CONF_SCRIPT}  ${CONF_TLS_SCRIPT}  ${SDNC_CONTAINER_NAME}  ${NETCONF_PNP_SIM_CONTAINER_NAME}
    Should Be True  ${exit_code}  Configure TLS Connection should be successful

Run Cert Service Client And Validate JKS File Creation And Client Exit Code
    [Documentation]  Run Cert Service Client Container And Validate Exit Code For SDNC
    [Arguments]   ${env_file}  ${CONTAINER_NAME}  ${expected_exit_code}
    ${exit_code}=  Run Client Container  ${DOCKER_CLIENT_IMAGE}  ${CLIENT_CONTAINER_NAME}  ${env_file}  ${CERT_SERVICE_ADDRESS}${CERT_SERVICE_ENDPOINT}  ${CERT_SERVICE_NETWORK}
    ${can_open}=  Can Open Keystore And Truststore With Pass
    ${install_certs}=  Can Install Keystore And Truststore Certs  ${CONF_SCRIPT}  ${CONTAINER_NAME}
    Remove Client Container And Save Logs  ${CLIENT_CONTAINER_NAME}  positive_path
    Should Be Equal As Strings  ${exit_code}  ${expected_exit_code}  Client return: ${exitcode} exit code, but expected: ${expected_exit_code}
    Should Be True  ${can_open}  Cannot Open Keystore/TrustStore by Passphrase
    Should Be True  ${install_certs}  Cannot Install Keystore/Truststore