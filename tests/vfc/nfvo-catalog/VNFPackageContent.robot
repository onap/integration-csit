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
${request_csar}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/files/vgw.csar


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

Upload VNF Package Content
    Log   Upload VNF Package Content
    [Documentation]    The objective is to test the upload of a VNF Package Content in Zip format.
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}
    ${headers}    Create Dictionary    Accept=application/json
    &{fileParts}=    Create Dictionary
    Create Multi Part   ${fileParts}  file  ${request_csar}
    Log  ${fileParts}
    ${resp}=  Put Request  web_session  ${vnf_packages_url}/${packageId}/package_content  files=${fileParts}  headers=${headers}
    Log  ${resp.status_code}    
    Should Be Equal As Strings    202    ${resp.status_code}
    Log    Received 202 Accepted as expected
  
GET Individual VNF Package Content
    Log    GET Individual VNF Package Content
    [Documentation]    The objective is to test the retrieval of an individual VNF package content
    ${headers}            Create Dictionary    Content-Type=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${vnf_packages_url}/${packageId}/package_content
    Should Be Equal As Strings    200    ${resp.status_code}

Check Postcondition
    Log    Check Postcondition
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${vnf_packages_url}/${packageId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ONBOARDED    ${response_json['onboardingState']}
	
POST Individual VNF Package Content - Method not implemented
    Log    POST Individual VNF Package Content - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create new VNF Package content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${vnf_packages_url}/${packageId}/package_content
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH Individual VNF Package Content - Method not implemented
    Log    PATCH Individual VNF Package Content - Method not implemented
    [Documentation]    The objective is to test that PATCH  method is not allowed to update a VNF Package content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${vnf_packages_url}/${packageId}/package_content
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE Individual VNF Package Content - Method not implemented
    Log    DELETE Individual VNF Package Content - Method not implemented
    [Documentation]    The objective is to test that DELETE  method is not allowed to delete a VNF Package content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Delete Request          web_session     ${vnf_packages_url}/${packageId}/package_content
    Should Be Equal As Strings    405    ${resp.status_code}

*** Keywords ***
Create Multi Part
    [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}  ${content}=${None}
    ${fileData}=  Run Keyword If  '''${content}''' != '''${None}'''  Set Variable  ${content}
    ...            ELSE  Get Binary File  ${filePath}
    ${fileDir}  ${fileName}=  Split Path  ${filePath}
    ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
    Set To Dictionary  ${addTo}  ${partName}=${partData}