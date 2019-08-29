*** Variables ***
### Orchestration Polling Properties ###
${POLL_WAIT_TIME}    5
${MEGA_POLL_WAIT_TIME}    5
${MAX_POLL_COUNT}    72

### Common Properties ###
${VNFS}     vnfs
${VFMODULES}     vfModules
${SO_REST_URI}       /onap/so/infra/serviceInstantiation/v7/serviceInstances
${SO_ORCHESTRATION_REQUESTS_URI}       /onap/so/infra/orchestrationRequests/v7
${SO_HEALTHCHECK_URI}    /manage/health

${SO_AUDIT_REST_URI}    /audit/v1/services/

### Layer3 Properties ###
&{SO_LAYER3_HEADERS}     Content-Type=application/xml     Accept=application/xml     Authorization=Basic YXBpaEJwbW46Y2FtdW5kYS1SMTUxMiE=
### Service Properties ###
${SO_REST_URI_CREATE_SERVICE}    ${SO_REST_URI}
${SO_REST_URI_DELETE_SERVICE}    ${SO_REST_URI}

### VNF Module Properties ###
${SO_REST_URI_CREATE_VFMODULE}    ${SO_REST_URI}/<SERVICEINSTANCEID>/vnfs/<VNFINSTANCEID>/vfModules
${SO_REST_URI_DELETE_VFMODULE}    ${SO_REST_URI}/<SERVICEINSTANCEID>/vnfs/<VNFINSTANCEID>/vfModules/<VFMODULEINSTANCEID>
### Messages ###
${TIME_OUT_MESSAGE}    No Successful response within specified time
${ORCH_FAILURE_MESSAGE}    Orchestration request has failed

#####  VF SPECIFIC PROPERTIES  #####
${INVALID_SERVICE_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid serviceInstanceId is specified"
${INVALID_VNF_INST_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid vnfInstanceId is specified"
${DELETE_VNF_FAIL_MSG}    "Can't Delete Generic Vnf. Generic Vnf is still in use."

#####  NETWORK SPECIFIC PROPERTIES  #####
${INVALID_NW_INST_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid networkInstanceId is specified"
${INV_MODEL_NAME_MSG}    "Received error from Network Adapter: Unknown Network Type: CONTRAIL_INTERNAL"
${BLANK_MODEL_NAME_MSG}    "Error parsing request.${SPACE}${SPACE}No valid modelName is specified"
${INV_REGION_ID_MSG}    "Received error from Network Adapter: Cloud Site [RegionTwo] not found"
${BLANK_REGION_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid lcpCloudRegionId is specified"
${INV_TENANT_MSG}     "Received error from Network Adapter: 404 Not Found: "
${BLANK_TENANT_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid tenantId is specified"
${INV_SOURCE_MSG}    "Recipe does not exist in catalog DB"
${BLANK_SOURCE_MSG}    "Error parsing request.${SPACE}${SPACE}No valid source is specified"
${BLANK_INVAR_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid modelInvariantId is specified"
${BLANK_VER_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid modelVersionId is specified"
${BLANK_REQ_ID_MSG}    "Error parsing request.${SPACE}${SPACE}No valid requestorId is specified"

### Orchestration Constants ###
${ORCH_REQUEST_COMPLETE}    COMPLETE
${ORCH_REQUEST_COMPLETED}    COMPLETED
${ORCH_REQUEST_FAILED}    FAILED
${ORCH_REQUEST_IN_PROGRESS}     IN_PROGRESS

### MODEL TYPE ###
${MODEL_TYPE_SERVICE}    service
${MODEL_TYPE_VNF}    vnf
${MODEL_TYPE_VFMODULE}    vfModule
${MODEL_TYPE_VOLUME_GROUP}      volumeGroup
${MODEL_TYPE_NETWORK}     network
${INV_MODEL_TYPE_VNF}    vnf1
${INVALID_MODEL_TYPE}             INVALID_MODEL_TYPE
${INVALID_SERVICE_MODEL_NAME}     INVALID_SERVICE_MODEL
${INVALID_VFMODULE_MODEL_NAME}    INVALID_VFMODULE_MODEL
${INVALID_CLOUD_REGION_ID}        INVALID_CLR

### CLOUD DATA ###
${TENANT_ID}             22eb191dd41a4f3c9be370fc638322f4