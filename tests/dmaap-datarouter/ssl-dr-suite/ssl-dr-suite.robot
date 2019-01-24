*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String
Library           Process

*** Variables ***
${TARGET_URL}                      https://dmaap-dr-prov:8443/
${CREATE_FEED_DATA}                {"name": "CSIT_Test", "version": "v1.0.0", "description": "CSIT_Test", "business_description": "CSIT_Test", "suspend": false, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": [],  "endpoint_ids": [{"password": "dradmin", "id": "dradmin"}]}}
${SUBSCRIBE_DATA}                  {"delivery":{ "url":"http://${DR_SUB_IP}:7070/",  "user":"LOGIN", "password":"PASSWORD", "use100":true}, "metadataOnly":false, "suspend":false, "groupid":29, "subscriber":"dmaap-subscriber"}
${FEED_CONTENT_TYPE}               application/vnd.att-dr.feed
${SUBSCRIBE_CONTENT_TYPE}          application/vnd.att-dr.subscription
${PUBLISH_FEED_CONTENT_TYPE}       application/octet-stream
${CLI_VERIFY_SUB_RECEIVED_FILE}    docker exec subscriber-node /bin/sh -c "ls /opt/app/subscriber/delivery | grep csit_test"

*** Test Cases ***
Run Feed Creation
    [Documentation]                 Feed Creation
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL}         ${CREATE_FEED_DATA}    ${FEED_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

Run Subscribe to Feed
    [Documentation]                 Subscribe to Feed
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL}subscribe/1    ${SUBSCRIBE_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL}subscribe/1
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

Run Publish Feed
    [Documentation]                 Publish to Feed
    [Timeout]                       1 minute
    Sleep                           10s                              Behaviour was noticed where feed was not created in time for publish to be sent
    ${resp}=                        PutCall                          ${TARGET_URL}publish/1/csit_test   ${CREATE_FEED_DATA}      ${PUBLISH_FEED_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL}publish/1/csit_test
    ${redirect_location}=           Set Variable                     ${resp.headers['Location']}
    log                             ${redirect_location}
    ${resp}=                        PutCall                          ${redirect_location}    ${CREATE_FEED_DATA}      ${PUBLISH_FEED_CONTENT_TYPE}    dradmin
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

Verify Subscriber Received Published File
    [Documentation]                 Verify file is delivered on datarouter-subscriber
    [Timeout]                       1 minute
    Sleep                           5s                             Time to allow subscriber to receive the file
    ${cli_cmd_output}=              Run Process                     ${CLI_VERIFY_SUB_RECEIVED_FILE}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}            0
    Should Contain                  ${cli_cmd_output.stdout}        csit_test

*** Keywords ***
PostCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.post('${url}', data='${data}', headers=${headers}, verify=True)    requests
    [Return]         ${resp}

PutCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}    Authorization=Basic ZHJhZG1pbjpkcmFkbWlu
    ${resp}=         Evaluate            requests.put('${url}', data='${data}', headers=${headers}, verify=True, allow_redirects=False)    requests
    [Return]         ${resp}

DeleteCall
    [Arguments]      ${url}              ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}
    ${resp}=         Evaluate            requests.delete('${url}', headers=${headers}, verify=True)    requests
    [Return]         ${resp}
