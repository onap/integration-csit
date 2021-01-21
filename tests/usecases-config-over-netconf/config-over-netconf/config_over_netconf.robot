*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDNC_KEYSTORE_CONFIG_PATH}    /config/netconf-keystore:keystore
${SDNC_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/pnf-simulator
${PNFSIM_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/pnf-simulator/yang-ext:mount/mynetconf:netconflist
${BP_UPLOAD_URL}    /api/v1/blueprint-model/publish
${BP_PROCESS_URL}    /api/v1/execution-service/process
${BP_ARCHIVE_PATH}    ${CURDIR}/data/blueprint_archive.zip


*** Test Cases ***
Test SDNC Keystore
    [Documentation]    Checking keystore after SDNC installation
    Create Session   sdnc  http://localhost:8282/restconf
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    sdnc    ${SDNC_KEYSTORE_CONFIG_PATH}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${keystoreContent}=    Convert To String    ${resp.content}
    Log to console  *************************
    Log to console  ${resp.content}
    Log to console  *************************

Test BP-PROC upload blueprint archive
    [Documentation]    Upload Blueprint archive to BP processor
    Create Session   blueprint  http://localhost:8000
    ${bp_archive}=    Get Binary File    ${BP_ARCHIVE_PATH}
    &{bp_file}=    create Dictionary    file    ${bp_archive}
    &{headers}=  Create Dictionary    Authorization=Basic Y2NzZGthcHBzOmNjc2RrYXBwcw==
    ${resp}=    Post Request    blueprint    ${BP_UPLOAD_URL}    files=${bp_file}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200

Test BP-PROC CONFIG-ASSIGN
    [Documentation]    Send config-assign request to BP-Proc
    Create Session   blueprint  http://localhost:8000
    ${config-assign}=    Get File     ${CURDIR}${/}data${/}config-assign.json
    Log to console  ${config-assign}
    &{headers}=  Create Dictionary    Authorization=Basic Y2NzZGthcHBzOmNjc2RrYXBwcw==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    blueprint    ${BP_PROCESS_URL}    data=${config-assign}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200

Test BP-PROC CONFIG-DEPLOY
    [Documentation]    Send config-deploy request to BP-Proc
    Create Session   blueprint  http://localhost:8000
    ${config-deploy}=    Get File     ${CURDIR}${/}data${/}config-deploy.json
    Log to console  ${config-deploy}
    &{headers}=  Create Dictionary    Authorization=Basic Y2NzZGthcHBzOmNjc2RrYXBwcw==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    blueprint    ${BP_PROCESS_URL}    data=${config-deploy}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200

Test PNF Configuration update
    [Documentation]    Checking PNF configuration params
    Create Session   sdnc  http://localhost:8282/restconf
    ${mount}=    Get File     ${CURDIR}${/}data${/}mount.xml
    Log to console  ${mount}
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
    ${resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    201
    Sleep  10
    &{headers1}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp1}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers1}
    Should Be Equal As Strings    ${resp1.status_code}    200
    Log to console  ${resp1.content}
    Should Contain  ${resp1.text}     {"netconf-id":30,"netconf-param":3000}
