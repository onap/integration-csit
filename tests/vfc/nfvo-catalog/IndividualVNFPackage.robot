*** Settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
${catalog_port}            8806
${vnf_packages_url}         /api/vnfpkgm/v1/vnf_packages

#json files
${request_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/CreateVnfPkgInfoRequest.json


#global variables
${packageId}

*** Test Cases ***
Create new VNF Package Resource for pre-condition
    Log    Create new VNF Package Resource for pre-condition
    ${json_value}=     json_from_file      ${request_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${vnf_packages_url}    ${json_string}
    Should Be Equal As Strings    201   ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    CREATED    ${response_json['onboardingState']}
    ${packageId}=    Convert To String      ${response_json['id']}
    Set Global Variable     ${packageId}

GET Individual VNF Package
    Log    GET Individual VNF Package
    [Documentation]    The objective is to test the retrieval of an individual VNF package information
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${vnf_packages_url}/${packageId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ${packageId}    ${response_json['id']}
    Should Be Equal As Strings    DISABLED    ${response_json['operationalState']}

PUT Individual VNF Package - Method not implemented
    Log    PUT Individual VNF Package - Method not implemented
    [Documentation]    The objective is to test that PUT method is not allowed to modify a VNF Package
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Put Request          web_session     ${vnf_packages_url}/${packageId}
    Should Be Equal As Strings    405    ${resp.status_code}

POST Individual VNF Package - Method not implemented
    Log    POST Individual VNF Package - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create new VNF Package
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${vnf_packages_url}/${packageId}
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE Individual VNF Package
    Log   DELETE Individual VNF Package
    [Documentation]    The objective is to test the deletion of an individual VNF Package
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}    headers=${headers}
    ${resp}=    Delete Request    web_session     ${vnf_packages_url}/${packageId}
    Should Be Equal As Strings    204    ${resp.status_code}
