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
${ns_descriptors_url}         /api/nsd/v1/ns_descriptors

#json files
${request_json}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/jsons/CreateNsdInfoRequest.json
${request_csar}    ${SCRIPTS}/../tests/vfc/nfvo-catalog/files/ns_vgw.csar

#global variables
${nsdId}

*** Test Cases ***
Create new Network Service Descriptor Resource for pre-condition
    Log    Create new Network Service Descriptor Resource for pre-condition
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

Check Precondition
    Log    Check Precondition
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${vnf_packages_url}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ONBOARDED    ${response_json[0]['onboardingState']}

Upload NSD Content as Zip file
    Log   Upload NSD Content as Zip file
    [Documentation]    The objective is to test the upload of an NSD Content in Zip format
    Create Session    web_session    http://${CATALOG_IP}:${catalog_port}
    ${headers}    Create Dictionary    Accept=application/json
    &{fileParts}=    Create Dictionary
    Create Multi Part   ${fileParts}  file  ${request_csar}
    Log  ${fileParts}
    ${resp}=  Put Request  web_session  ${ns_descriptors_url}/${nsdId}/nsd_content  files=${fileParts}  headers=${headers}
    Log  ${resp.status_code}    
    Should Be Equal As Strings    204    ${resp.status_code}
    Log    Received 204 Accepted as expected
  
GET NSD Content
    Log    GET NSD Content
    [Documentation]    The objective is to test the retrieval of the NSD Content
    ${headers}            Create Dictionary    Content-Type=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${ns_descriptors_url}/${nsdId}/nsd_content
    Should Be Equal As Strings    200    ${resp.status_code}

Check Postcondition
    Log    Check Postcondition
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Get Request          web_session     ${ns_descriptors_url}/${nsdId}
    Should Be Equal As Strings    200    ${resp.status_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Strings    ONBOARDED    ${response_json['nsdOnboardingState']}
	
POST NSD Content - Method not implemented
    Log    POST NSD Content - Method not implemented
    [Documentation]    The objective is to test that POST method is not allowed to create new Network Service Descriptor content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Post Request          web_session     ${ns_descriptors_url}/${nsdId}/nsd_content
    Should Be Equal As Strings    405    ${resp.status_code}

PATCH NSD Content - Method not implemented
    Log    PATCH NSD Content - Method not implemented
    [Documentation]    The objective is to test that PATCH  method is not allowed to update a Network Service Descriptor content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Patch Request          web_session     ${ns_descriptors_url}/${nsdId}/nsd_content
    Should Be Equal As Strings    405    ${resp.status_code}

DELETE NSD Content - Method not implemented
    Log    DELETE NSD Content - Method not implemented
    [Documentation]    The objective is to test that DELETE  method is not allowed to delete a Network Service Descriptor content
    ${headers}            Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session        web_session          http://${CATALOG_IP}:${catalog_port}      headers=${headers}
    ${resp}=              Delete Request          web_session     ${ns_descriptors_url}/${nsdId}/nsd_content
    Should Be Equal As Strings    405    ${resp.status_code}

*** Keywords ***
Create Multi Part
    [Arguments]  ${addTo}  ${partName}  ${filePath}  ${contentType}=${None}  ${content}=${None}
    ${fileData}=  Run Keyword If  '''${content}''' != '''${None}'''  Set Variable  ${content}
    ...            ELSE  Get Binary File  ${filePath}
    ${fileDir}  ${fileName}=  Split Path  ${filePath}
    ${partData}=  Create List  ${fileName}  ${fileData}  ${contentType}
    Set To Dictionary  ${addTo}  ${partName}=${partData}