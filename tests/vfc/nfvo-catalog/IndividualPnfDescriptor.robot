*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
${catalog_port}            8806
${pnf_descriptors_url}         /api/nsd/v1/pnf_descriptors

#json files
${request_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/CreatePnfdInfoRequest.json

#global variables
${pnfdId}

*** Test Cases ***
Create new PNF Descriptor Resource
    Log    Create new PNF Descriptor Resource
    [Documentation]    The objective is to test the creation of a new Create new PNF Descriptor resource
    ${json_value}=     json_from_file      ${request_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${pnf_descriptors_url}    ${json_string}
    Should Be Equal As Strings    201   ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    CREATED    ${response_json['pnfdOnboardingState']}
    ${pnfdId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${pnfdId}

GET Individual PNF Descriptor Information
    Log    GET Individual PNF Descriptor Information
    [Documentation]    The objective is to test the retrieval of an individual PNF Descriptor information
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${pnf_descriptors_url}/${pnfdId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ${pnfdId}    ${response_json['id']}

POST Individual PNF Descriptor - Method not implemented
    Log    POST Individual PNF Descriptor - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create a new PNF Descriptor
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${pnf_descriptors_url}/${pnfdId}
    Should Be Equal As Strings    405    ${resp.status_code}

PUT Individual PNF Descriptor - Method not implemented
    Log    PUT Individual PNF Descriptor - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to modify a new PNF Descriptor
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${pnf_descriptors_url}/${pnfdId}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE PNF Descriptor
    Log   DELETE PNF Descriptor
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${pnf_descriptors_url}/${pnfdId}
    Should Be Equal As Strings    204    ${resp.status_code}
