*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ArchiveLibrary

*** Variables ***
${VNF_PACKAGE_ID}=    73522444-e8e9-49c1-be29-d355800aa349
${PACKAGE_MANAGEMENT_BASE_URL}=    /so/vnfm-adapter/v1/vnfpkgm/v1
${BASIC_AUTH}=    Basic dm5mbTpwYXNzd29yZDEk
${TEST_DIR}=    CSIT_ETSI_TEMP

*** Test Cases ***
Get VNF Packages
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nGetting VNF Packages from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/vnf_packages    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse Content:\n${response.content}
    ${json_response}    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    ${vnf_package_id}=    Set Variable    ${json_response}[0][id]
    Should Be Equal As Strings    '${vnf_package_id}'    '${VNF_PACKAGE_ID}'
    ${expected}=    Get File    ${CURDIR}${/}data${/}responses${/}expectedVnfPackage.json
    ${expected}=    Evaluate    json.loads(r"""${expected}""", strict=False)    json
    Should Be Equal    ${json_response[0]}    ${expected}
    Log To Console    \nexecuted with expected result

Get VNF Package By VNF Package Id
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/json
    Log To Console    \nGetting VNF Package with id ${VNF_PACKAGE_ID} from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/vnf_packages/${VNF_PACKAGE_ID}    headers=${headers}
    Log To Console    \nResponse:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Log To Console    \nResponse:\n${response.content}
    ${json_response}    Evaluate    json.loads(r"""${response.content}""", strict=False)    json
    ${vnf_package_id}=    Set Variable    ${json_response}[id]
    Should Be Equal As Strings    '${vnf_package_id}'    '${VNF_PACKAGE_ID}'
    ${expected}=    Get File    ${CURDIR}${/}data${/}responses${/}expectedVnfPackage.json
    ${expected}=    Evaluate    json.loads(r"""${expected}""", strict=False)    json
    Should Be Equal    ${json_response}    ${expected}
    Log To Console    \nexecuted with expected result

Get VNF Package Content
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/zip
    Log to Console    \nGetting Vnf Package Content from Vnf Package with id ${vnf_package_id} from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/vnf_packages/${vnf_package_id}/package_content    headers=${headers}
    Log To Console    Response:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Create Directory    ${TEMPDIR}${/}${TEST_DIR}
    Empty Directory    ${TEMPDIR}${/}${TEST_DIR}
    Create Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}actualVnfPackageContent.csar    ${response.content}
    Should Be Equal File Size    ${TEMPDIR}${/}${TEST_DIR}${/}actualVnfPackageContent.csar    ${CURDIR}${/}data${/}responses${/}expectedVnfPackageContent.csar
    Extract Zip File    ${TEMPDIR}${/}${TEST_DIR}${/}actualVnfPackageContent.csar    ${TEMPDIR}${/}${TEST_DIR}/actualContent
    Extract Zip File    ${CURDIR}${/}data${/}responses${/}expectedVnfPackageContent.csar    ${TEMPDIR}${/}${TEST_DIR}${/}expectedContent
    Should Contain Same Content    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent    ${TEMPDIR}${/}${TEST_DIR}${/}expectedContent
    File Should Exist    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}Definitions${/}MainServiceTemplate.yaml
    File Should Exist    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}Definitions${/}onap_dm.yaml
    File Should Exist    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}TOSCA-Metadata${/}TOSCA.meta
    ${expectedMainServiceTemplate}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}expectedContent${/}Definitions${/}MainServiceTemplate.yaml
    ${actualMainServiceTemplate}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}Definitions${/}MainServiceTemplate.yaml
    Should Be Equal As Strings    ${expectedMainServiceTemplate}    ${actualMainServiceTemplate}
    ${expectedOnapDm}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}expectedContent${/}Definitions${/}onap_dm.yaml
    ${actualOnapDm}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}Definitions${/}onap_dm.yaml
    Should Be Equal As Strings    ${expectedOnapDm}    ${actualOnapDm}
    ${expectedToscaMeta}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}expectedContent${/}TOSCA-Metadata${/}TOSCA.meta
    ${actualToscaMeta}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}actualContent${/}TOSCA-Metadata${/}TOSCA.meta
    Should Be Equal As Strings    ${expectedOnapDm}    ${actualOnapDm}
    Remove Directory    ${TEMPDIR}${/}${TEST_DIR}    recursive=True
    Log To Console    \nexecuted with expected result

Get VNF Package VNFD
    Create Session    so_vnfm_adapter_session    http://${REPO_IP}:9092
    &{headers}=    Create Dictionary    Authorization=${BASIC_AUTH}    Content-Type=application/json    Accept=application/zip
    Log to Console    \nGetting Vnfd from Vnf Package with id ${vnf_package_id} from so-vnfm-adapter
    ${response}=    Get On Session    so_vnfm_adapter_session    ${PACKAGE_MANAGEMENT_BASE_URL}/vnf_packages/${vnf_package_id}/vnfd    headers=${headers}
    Log To Console    Response:${response}
    Run Keyword If    '${response.status_code}' == '200'    Log To Console    \nexecuted with expected result
    Should Be Equal As Strings    '${response.status_code}'    '200'
    Create Directory    ${TEMPDIR}${/}${TEST_DIR}
    Empty Directory    ${TEMPDIR}${/}${TEST_DIR}
    Create Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}actualVnfd.zip    ${response.content}
    Extract Zip File    ${TEMPDIR}${/}${TEST_DIR}${/}actualVnfd.zip    ${TEMPDIR}${/}${TEST_DIR}
    File Should Exist    ${TEMPDIR}${/}${TEST_DIR}${/}MainServiceTemplate.yaml
    File Should Exist    ${TEMPDIR}${/}${TEST_DIR}${/}onap_dm.yaml
    ${expectedMainServiceTemplate}=    Get Binary File    ${CURDIR}${/}data${/}responses${/}expectedVnfd${/}MainServiceTemplate.yaml
    ${actualMainServiceTemplate}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}MainServiceTemplate.yaml
    Should Be Equal As Strings    ${expectedMainServiceTemplate}    ${actualMainServiceTemplate}
    ${expectedOnapDm}=    Get Binary File    ${CURDIR}${/}data${/}responses${/}expectedVnfd${/}onap_dm.yaml
    ${actualOnapDm}=    Get Binary File    ${TEMPDIR}${/}${TEST_DIR}${/}onap_dm.yaml
    Should Be Equal As Strings    ${expectedOnapDm}    ${actualOnapDm}
    Remove Directory    ${TEMPDIR}${/}${TEST_DIR}    recursive=True
    Log To Console    \nexecuted with expected result

*** Keywords ***
Should Be Equal File Size
    [Arguments]    ${file1}    ${file2}
    Log To Console    \nComparing file sizes between ${file1} and ${file2}
    ${file1size}=    Get File Size    ${file1}
    ${file2size}=    Get File Size    ${file2}
    Should Be Equal    ${file1size}    ${file2size}
    Log To Console    Files are the same size

Should Contain Same Content
    [Arguments]    ${dir1}    ${dir2}
    Log To Console    \nComparing directory contents between:
    Log To Console    Directory 1: ${dir1}
    Log To Console    Directory 2: ${dir2}
    @{dir1files}=    List Files In Directory    ${dir1}
    Log To Console    Files in directory 1: @{dir1files}
    @{dir2files}=    List Files In Directory    ${dir2}
    Log To Console    Files in directory 2: @{dir2files}
    Lists Should Be Equal    ${dir1files}    ${dir2files}
    FOR    ${file}    IN    @{dir1files}
        Should Be Equal File Size    ${dir1}${/}${file}    ${dir2}${/}${file}
    END
    @{dir1directories}=    List Directories In Directory    ${dir1}
    Log To Console    Directories in directory 1: ${dir1directories}
    @{dir2directories}=    List Directories In Directory    ${dir2}
    Log To Console    Directories in directory 2: ${dir2directories}
    Lists Should Be Equal     ${dir1directories}    ${dir2directories}
    FOR    ${directory}    IN    @{dir1directories}
        Should Contain Same Content    ${dir1}${/}${directory}    ${dir2}${/}${directory}
    END
    Log To Console    executed with expected result
