*** Settings ***
Library       json
Library       OperatingSystem
Resource          ./resources/common-keywords.robot

Suite Teardown  Delete All Sessions

*** Variables ***
${osdf_host}    ${OSDF_HOSTNAME}:${OSDF_PORT}
&{placement_auth} =    username=test   password=testpwd
&{wrong_authorization} =    username=test   password=test
&{pci_auth}=    username=pci_test   password=pci_testpwd

*** Test Cases ***
Healthcheck
    [Documentation]    It sends a REST GET request to healthcheck url
    ${resp}=         Http Get         ${osdf_host}   /api/oof/v1/healthcheck
    Should Be Equal As Integers    ${resp.status_code}    200

SendPlacementWithInvalidAuth
    [Documentation]    It sends a POST request to osdf fail authentication
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}placement_request.json
    ${resp}=         Http Post        host=${osdf_host}   restUrl=/api/oof/v1/placement     data=${data}    auth=${wrong_authorization}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal     Unauthorized, check username and password    ${response_json['serviceException']['text']}
    Should Be Equal As Integers    ${resp.status_code}    401

SendPlacementWithValidAuth
    [Documentation]    It sends a POST request to osdf with correct authentication
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}placement_request.json
    ${resp}=         Http Post        host=${osdf_host}   restUrl=/api/oof/v1/placement     data=${data}    auth=${placement_auth}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    202
    Should Be Equal     accepted    ${response_json['requestStatus']}

SendPCIOptimizationWithAuth
    [Documentation]    It sends a POST request PCI Optimization service

    ${data}=         Get Binary File     ${CURDIR}${/}data${/}pci-opt-request.json
    ${resp}=         Http Post        host=${osdf_host}   restUrl=/api/oof/v1/pci     data=${data}    auth=${pci_auth}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal As Integers    ${resp.status_code}    202
    Should Be Equal     accepted    ${response_json['requestStatus']}





