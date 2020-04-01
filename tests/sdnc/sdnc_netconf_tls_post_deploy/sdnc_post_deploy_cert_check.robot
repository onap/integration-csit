*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDNC_KEYSTORE_CONFIG_PATH}    /config/netconf-keystore:keystore
${SDNC_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/netopeer2
#${PNFSIM_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/netopeer2/yang-ext:mount/mynetconf:netconflist
${PNFSIM_MOUNT_PATH}    /config/network-topology:network-topology/topology/topology-netconf/node/netopeer2

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

 Test SDNC PNF Mount
     [Documentation]    Checking PNF mount after SDNC installation
     Create Session   sdnc  http://localhost:8282/restconf
     ${mount}=    Get File     ${CURDIR}${/}data${/}mount.xml
     Log to console  ${mount}
     &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/xml    Accept=application/xml
     ${resp}=    Put Request    sdnc    ${SDNC_MOUNT_PATH}    data=${mount}    headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}    201
     Sleep  30
     &{headers1}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
     ${resp1}=    Get Request    sdnc    ${PNFSIM_MOUNT_PATH}    headers=${headers1}
     Should Be Equal As Strings    ${resp1.status_code}    200
     Log to console  ${resp1.content}
     Should Contain  ${resp1.content}     netconf-id
     Should Contain  ${resp1.content}     netconf-param