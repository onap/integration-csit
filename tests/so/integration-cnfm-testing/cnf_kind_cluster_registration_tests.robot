*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem

*** Variables ***
${CNFM_LCM_BASE_URL}=         /so/so-cnfm/v1/api/kube-config
${CLOUD_OWNER_VALUE}=         CloudOwner
${CLOUD_REGION_VALUE}=        EtsiCloudRegion
${TENANT_ID_VALUE}=           693c7729b2364a26a3ca602e6f66187d
${UPLOAD_KUBE_CONFIG_URL}=    ${CNFM_LCM_BASE_URL}/cloudOwner/${CLOUD_OWNER_VALUE}/cloudRegion/${CLOUD_REGION_VALUE}/tenantId/${TENANT_ID_VALUE}/upload

*** Test Cases ***

Register kind Cluster with CNFM
    Create Session   cnfm_lcm_session  http://${REPO_IP}:9888
    Run Keyword If    "${KIND_CLUSTER_KUBE_CONFIG_FILE}"!="${EMPTY}"   Log to Console    \nKIND_CLUSTER_KUBE_CONFIG_FILE :${KIND_CLUSTER_KUBE_CONFIG_FILE}
    ...    ELSE    Fail    \nInvalid Kube-config path :${KIND_CLUSTER_KUBE_CONFIG_FILE} received

    ${file}=  Get File For Streaming Upload  ${KIND_CLUSTER_KUBE_CONFIG_FILE}
    ${files}=   Create Dictionary  file    ${file}
    ${resp}=    Put On Session    cnfm_lcm_session    ${UPLOAD_KUBE_CONFIG_URL}     files=${files}
    Should Be Equal As Strings    '${resp.status_code}'    '202'