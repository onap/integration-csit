*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${SLEEP_INTERVAL_SEC}=   5
${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}=     48     # Represents the maximum number of attempts that will be made before a timeout. It sleeps for SLEEP_INTERVAL_SEC seconds before retry.

*** Test Cases ***
OnBoard VNF Package In Etsi Catalog
    Create Session   etsi_catalog_session  http://${REPO_IP}:8806
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}vnfPackageOnboardRequest.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Post On Session    etsi_catalog_session    /api/catalog/v1/vnfpackages    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '202'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '202'
    log to console      ${resp.content}
    ${onboarding_job_json_response}=    Evaluate     json.loads(r"""${resp.content}""", strict=False)    json
    ${job_ID}=          Set Variable         ${onboarding_job_json_response}[jobId]
    Should Not Be Empty    ${job_ID}
    ${actual_job_status}=    Set Variable    ""

    FOR    ${INDEX}    IN RANGE    ${MAXIMUM_ATTEMPTS_BEFORE_TIMEOUT}
       ${onboarding_job_status_request}=   Get On Session  etsi_catalog_session   /api/catalog/v1/jobs/${job_ID}
       Run Keyword If  '${onboarding_job_status_request.status_code}' == '200'  log to console   \nexecuted with expected result
       log to console      ${onboarding_job_status_request.content}

       ${onboarding_job_status_json_response}=    Evaluate     json.loads(r"""${onboarding_job_status_request.content}""", strict=False)    json

       ${actual_job_status}=    Set Variable    ""

       ${response_descriptor_exists}=  Run Keyword And Return Status    Get From Dictionary    ${onboarding_job_status_json_response}    responseDescriptor
       ${status_exists}=  Run Keyword And Return Status    Get From Dictionary    ${onboarding_job_status_json_response}[responseDescriptor]    status

       ${actual_job_status}=     Set Variable If   ${response_descriptor_exists} == True and ${status_exists} == True
       ...    ${onboarding_job_status_json_response}[responseDescriptor][status]

       Log To Console    Received actual repsonse status:${actual_job_status}
       Run Keyword If   '${actual_job_status}' == 'finished' or '${actual_job_status}' == 'error' or '${actual_job_status}' == 'timeout'      Exit For Loop
       log to console  Will try again after ${SLEEP_INTERVAL_SEC} seconds
       SLEEP   ${SLEEP_INTERVAL_SEC}
    END
    Log To Console     final repsonse status received: ${actual_job_status}
    Run Keyword If  '${actual_job_status}' == 'finished'  log to console   \nexecuted with expected result
    Should Be Equal As Strings    '${actual_job_status}'    'finished'

Distribute Service Template
    Create Session   sdc_controller_session  http://${REPO_IP}:8085
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}distributeServiceTemplate.json
    &{headers}=  Create Dictionary    Authorization=Basic bXNvX2FkbWluOnBhc3N3b3JkMSQ=    resource-location=/distribution-test-zip/unzipped/    Content-Type=application/json    Accept=application/json
    ${resp}=    Post On Session    sdc_controller_session    /test/treatNotification/v1    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '200'  log to console  \nexecuted with expected result
    Should Be Equal As Strings    '${resp.status_code}'    '200'
