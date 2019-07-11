*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
${catalog_port}            8806
${ns_descriptors_url}         /api/nsd/v1/ns_descriptors

#json files
${request_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/CreateNsdInfoRequest.json

#global variables
${nsdId}

*** Test Cases ***
Create new Network Service Descriptor Resource
    Log    Create new Network Service Descriptor Resource
    [Documentation]    The objective is to test the creation of a new Create new Network Service Descriptor resource
    ${json_value}=     json_from_file      ${request_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${ns_descriptors_url}    ${json_string}
    Should Be Equal As Strings    201   ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    CREATED    ${response_json['nsdOnboardingState']}
    ${nsdId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${nsdId}

GET all Network Service Descriptors Information
    Log    GET all Network Service Descriptors Information
    [Documentation]    The objective is to test the retrieval of all the Network Service Descriptors information
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${ns_descriptors_url}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ${nsdId}    ${response_json[0]['id']}

PUT all Network Service Descriptors - Method not implemented
    Log    PUT all Network Service Descriptors - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to modify existing Network Service Descriptors
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${ns_descriptors_url}
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH all Network Service Descriptors - Method not implemented
    Log    PATCH all Network Service Descriptors - Method not implemented
    [Documentation]    The objective is to test that PATCH method is not allowed to update existing Network Service Descriptors
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${ns_descriptors_url}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE all Network Service Descriptors - Method not implemented
    Log    DELETE all Network Service Descriptors - Method not implemented
    [Documentation]    The objective is to test that DELETE method is not allowed to delete existing Network Service Descriptors
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Delete Request          web_session     ${ns_descriptors_url}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE Network Service Descriptor
    Log   DELETE Network Service Descriptor
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${ns_descriptors_url}/${nsdId}
    Should Be Equal As Strings    204    ${resp.status_code}
