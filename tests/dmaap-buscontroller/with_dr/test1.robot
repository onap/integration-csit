*** Settings ***
Resource          ../../common.robot
Library           Collections
Library           json
Library           OperatingSystem
Library           RequestsLibrary
Library           HttpLibrary.HTTP
Library           String


*** Variables ***
${DBC_URI}     webapi
${DBC_URL}     http://${DMAAPBC_IP}:8080/${DBC_URI}
${LOC}          csit-sanfrancisco
${FEED1_DATA}  { "feedName":"feed1", "feedVersion": "csit", "feedDescription":"generated for CSIT", "owner":"dgl", "asprClassification": "unclassified" }
${FEED2_DATA}  { "feedName":"feed2", "feedVersion": "csit", "feedDescription":"generated for CSIT", "owner":"dgl", "asprClassification": "unclassified" }
${PUB2_DATA}   { "dcaeLocationName": "${LOC}", "username": "pub2", "userpwd": "topSecret123", "feedId": "2" }
${SUB2_DATA}   { "dcaeLocationName": "${LOC}", "username": "sub2", "userpwd": "someSecret123", "deliveryURL": "https://${DMAAPBC_IP}:8443/webapi/noURI", "feedId": "2" }


*** Test Cases ***
(DMAAP-441c1)
    [Documentation]        Create Feed w no clients POST ${DBC_URI}/feeds endpoint
    ${resp}=         PostCall     ${DBC_URL}/feeds    ${FEED1_DATA}
    Should Be Equal As Integers   ${resp.status_code}  200

(DMAAP-441c2)
    [Documentation]        Create Feed w clients POST ${DBC_URI}/feeds endpoint
    ${resp}=         PostCall     ${DBC_URL}/feeds    ${FEED2_DATA}
    Should Be Equal As Integers   ${resp.status_code}  200

(DMAAP-441c3)
    [Documentation]        Add Publisher to existing feed
    ${resp}=         PostCall      ${DBC_URL}/dr_pubs    ${PUB2_DATA}
    Should Be Equal As Integers    ${resp.status_code}  201
    ${JSON}=         Evaluate      json.loads(r"""${resp.content}""", strict=False)
    ${result}=       Set Variable  ${JSON['pubId']}
    Set Suite Variable             ${pubId}    ${result}

(DMAAP-441c4)
    [Documentation]        Add Subscriber to existing feed
    ${resp}=         PostCall      ${DBC_URL}/dr_subs    ${SUB2_DATA}
    Should Be Equal As Integers    ${resp.status_code}  201
    ${JSON}=         Evaluate      json.loads(r"""${resp.content}""", strict=False)
    ${result}=       Set Variable  ${JSON['subId']}
    Set Suite Variable             ${subId}    ${result}

(DMAAP-443)
    [Documentation]        List existing feeds
    Create Session     get          ${DBC_URL}
    ${resp}=         GET On Session    get       /feeds
    Should Be Equal As Integers     ${resp.status_code}  200

(DMAAP-444)
    [Documentation]        Delete existing subscriber
    ${resp}=         DelCall        ${DBC_URL}/dr_subs/${subId}
    Should Be Equal As Integers     ${resp.status_code}  204

(DMAAP-445)
    [Documentation]        Delete existing publisher
    ${resp}=         DelCall        ${DBC_URL}/dr_pubs/${pubId}
    Should Be Equal As Integers     ${resp.status_code}  204


*** Keywords ***
PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

DelCall
    [Arguments]    ${url}           
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.delete('${url}', headers=${headers},verify=False)    requests
    [Return]       ${resp}
