*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           Process
Library           String

*** Variables ***
${TARGET_URL}                       https://dmaap-dr-prov:8443/
${TARGET_URL_FEED}                  https://dmaap-dr-prov:8443/feed/1
${TARGET_URL_EXISTS_LOGGING}        https://dmaap-dr-prov:8443/feedlog/1?type=pub&filename=csit_test
${TARGET_URL_NOT_EXISTS_LOGGING}    https://dmaap-dr-prov:8443/feedlog/1?type=pub&filename=file_that_doesnt_exist
${TARGET_URL_SUBSCRIBE}             https://dmaap-dr-prov:8443/subscribe/1
${TARGET_URL_SUBSCRIPTION}          https://dmaap-dr-prov:8443/subs/1
${TARGET_URL_PUBLISH_PROV}          https://dmaap-dr-prov:8443/publish/1/csit_test
${TARGET_URL_PUBLISH_NODE}          https://dmaap-dr-node:8443/publish/1/csit_test
${TARGET_URL_DELETE_FILE}           https://dmaap-dr-node:8443/delete/2

${FEED_CONTENT_TYPE}                application/vnd.dmaap-dr.feed
${SUBSCRIBE_CONTENT_TYPE}           application/vnd.dmaap-dr.subscription
${PUBLISH_FEED_CONTENT_TYPE}        application/octet-stream

${CREATE_FEED_DATA}                 {"name": "CSIT_Test", "version": "m1.0", "description": "CSIT_Test", "business_description": "CSIT_Test", "suspend": false, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": [],  "endpoint_ids": [{"password": "dradmin", "id": "dradmin"}]}}
${UPDATE_FEED_DATA}                 {"name": "CSIT_Test", "version": "m1.0", "description": "UPDATED-CSIT_Test", "business_description": "CSIT_Test", "suspend": true, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": [],  "endpoint_ids": [{"password": "dradmin", "id": "dradmin"}]}}
${SUBSCRIBE_DATA}                   {"delivery":{ "url":"http://${DR_SUB_IP}:7070/",  "user":"LOGIN", "password":"PASSWORD", "use100":true}, "metadataOnly":false, "suspend":false, "groupid":29, "subscriber":"dradmin", "privilegedSubscriber":false}
${UPDATE_SUBSCRIPTION_DATA}         {"delivery":{ "url":"http://${DR_SUB_IP}:7070/",  "user":"dradmin", "password":"dradmin", "use100":true}, "metadataOnly":false, "suspend":true, "groupid":29, "subscriber":"dradmin", "privilegedSubscriber":false}
${SUBSCRIBE2_DATA}                  {"delivery":{ "url":"http://${DR_SUB2_IP}:7070/",  "user":"LOGIN", "password":"PASSWORD", "use100":true}, "metadataOnly":false, "suspend":false, "groupid":29, "subscriber":"privileged", "privilegedSubscriber":true}

${CLI_VERIFY_SUB_RECEIVED_FILE}     docker exec subscriber-node /bin/sh -c "ls /opt/app/subscriber/delivery | grep csit_test"
${CLI_VERIFY_FILE_REMAINS_ON_NODE}  docker exec datarouter-node /bin/sh -c "ls /opt/app/datartr/spool/s/0/2 | grep dmaap-dr-node | grep -v .M"

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
    ${resp}=                        PostCall                         ${TARGET_URL_SUBSCRIBE}    ${SUBSCRIBE_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL_SUBSCRIBE}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

Run Subscribe to Feed with Privileged Subscription
    [Documentation]                 Subscribe to Feed with privileged subscription
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL_SUBSCRIBE}    ${SUBSCRIBE2_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    privileged
    log                             ${TARGET_URL_SUBSCRIBE}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

Run Publish to Feed
    [Documentation]                 Publish to Feed
    [Timeout]                       1 minute
    Sleep                           10s                              Behaviour was noticed where feed was not created in time for publish to be sent
    ${resp}=                        PutCall                          ${TARGET_URL_PUBLISH_PROV}    ${CREATE_FEED_DATA}      ${PUBLISH_FEED_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL_PUBLISH_PROV}
    Should Contain                  ${resp.headers['Location']}      https://dmaap-dr-node:8443/publish/1/csit_test
    ${resp}=                        PutCall                          ${TARGET_URL_PUBLISH_NODE}    ${CREATE_FEED_DATA}      ${PUBLISH_FEED_CONTENT_TYPE}    dradmin
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

Verify Subscriber Received Published File
    [Documentation]                 Verify file is delivered to datarouter-subscriber
    [Timeout]                       1 minute
    Sleep                           5s                               Time to allow subscriber to receive the file
    ${cli_cmd_output}=              Run Process                      ${CLI_VERIFY_SUB_RECEIVED_FILE}        shell=yes
    Log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         csit_test


Verify File Remains On Privileged Subscriber And Delete It
    [Documentation]                 Verify file has not been deleted on datarouter-node and delete it using DELETE API
    [Timeout]                       1 minute
    ${cli_cmd_output}=              Run Process                      ${CLI_VERIFY_FILE_REMAINS_ON_NODE}        shell=yes
    log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             0
    Should Contain                  ${cli_cmd_output.stdout}         dmaap-dr-node
    ${resp}=                        DeleteCall                       ${TARGET_URL_DELETE_FILE}/${cli_cmd_output.stdout}   dradmin
    Should Be Equal As Strings      ${resp.status_code}              200
    log                             'JSON Response Code:'${resp}
    ${cli_cmd_output}=              Run Process                      ${CLI_VERIFY_FILE_REMAINS_ON_NODE}        shell=yes
    log                             ${cli_cmd_output.stdout}
    Should Be Equal As Strings      ${cli_cmd_output.rc}             1

Run Update Subscription
    [Documentation]                 Update Subscription to suspend and change delivery credentials
    [Timeout]                       1 minute
    ${resp}=                        PutCall                          ${TARGET_URL_SUBSCRIPTION}    ${UPDATE_SUBSCRIPTION_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL_SUBSCRIPTION}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              200
    log                             'JSON Response Code:'${resp}
    ${resp}=                        GetCall                          ${TARGET_URL_SUBSCRIPTION}    ${SUBSCRIBE_CONTENT_TYPE}    dradmin
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     "password":"dradmin","user":"dradmin"
    log                             'JSON Response Code:'${resp}

Run Update Feed
    [Documentation]                 Update Feed description and suspend
    [Timeout]                       1 minute
    ${resp}=                        PutCall                          ${TARGET_URL_FEED}    ${UPDATE_FEED_DATA}      ${FEED_CONTENT_TYPE}    dradmin
    log                             ${TARGET_URL_FEED}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              200
    log                             'JSON Response Code:'${resp}
    ${resp}=                        GetCall                          ${TARGET_URL_FEED}    ${FEED_CONTENT_TYPE}    dradmin
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     "UPDATED-CSIT_Test"
    log                             'JSON Response Code:'${resp}

Run Get With Filename That Exists
    [Documentation]                 Get publish record with a specified filename
    [Timeout]                       2 minutes
    sleep                           1 minute                         45 seconds needed to ensure logs have been updated
    ${resp}=                        GetCall                          ${TARGET_URL_EXISTS_LOGGING}    ${FEED_CONTENT_TYPE}    dradmin
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     "fileName":"csit_test"
    log                             'JSON Response Code:'${resp}

Run Get With Filename That Doesnt Exist
    [Documentation]                 Get publish record with a specified filename
    [Timeout]                       1 minute
    ${resp}=                        GetCall                          ${TARGET_URL_NOT_EXISTS_LOGGING}    ${FEED_CONTENT_TYPE}    dradmin
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     []
    log                             'JSON Response Code:'${resp}


Run Delete Subscription
    [Documentation]                 Delete Subscription
    [Timeout]                       1 minute
    ${resp}=                        DeleteCall                       ${TARGET_URL_SUBSCRIPTION}    dradmin
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

Run Delete Feed
    [Documentation]                 Delete Feed
    [Timeout]                       1 minute
    ${resp}=                        DeleteCall                       ${TARGET_URL_FEED}    dradmin
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

*** Keywords ***
PostCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-DMAAP-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.post('${url}', data='${data}', headers=${headers}, verify=True)    requests
    [Return]         ${resp}

PutCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-DMAAP-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}    Authorization=Basic ZHJhZG1pbjpkcmFkbWlu
    ${resp}=         Evaluate            requests.put('${url}', data='${data}', headers=${headers}, verify=True, allow_redirects=False)    requests
    [Return]         ${resp}

GetCall
    [Arguments]      ${url}              ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-DMAAP-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.get('${url}', headers=${headers}, verify=True)    requests
    [Return]         ${resp}

DeleteCall
    [Arguments]      ${url}              ${user}
    ${headers}=      Create Dictionary   X-DMAAP-DR-ON-BEHALF-OF=${user}
    ${resp}=         Evaluate            requests.delete('${url}', headers=${headers}, verify=True)    requests
    [Return]         ${resp}
