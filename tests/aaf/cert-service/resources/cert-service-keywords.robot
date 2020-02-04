*** Settings ***

Library 	      RequestsLibrary
*** Variables ***

${GLOBAL_APPLICATION_ID}                 robot-dcaegen2
${AAFCERT_URL}                           http://%{AAFCERT_IP}:8080

*** Keywords ***

Create sessions
    [Documentation]  Create all required sessions
    Create Session    aaf_cert_service_url    ${AAFCERT_URL}
    Set Suite Variable    ${http_session}    aaf_cert_service_url

Run Healthcheck
    [Documentation]  Run Healthcheck
    ${resp}= 	Get Request 	${http_session} 	/actuator/health
    Should Be Equal As Strings 	${resp.status_code} 	200