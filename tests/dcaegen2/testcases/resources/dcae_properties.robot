*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.

*** Variables ***

${GLOBAL_APPLICATION_ID}                 robot-dcaegen2
${GLOBAL_DCAE_CONSUL_URL}                http://135.205.228.129:8500
${GLOBAL_DCAE_CONSUL_URL1}               http://135.205.228.170:8500
${GLOBAL_DCAE_VES_URL}                   http://localhost:8443/eventlistener/v5
${GLOBAL_DCAE_USERNAME}                  console
${GLOBAL_DCAE_PASSWORD}                  ZjJkYjllMjljMTI2M2Iz
${VESC_HTTPS_USER}                       sample1
${VESC_HTTPS_PD}                         sample1
${VESC_HTTPS_WRONG_PD}                   sample
${VESC_HTTPS_WRONG_USER}                 sample
${VESC_CERT}                             %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/temporary.crt
${VESC_KEY}                              %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/temporary.key
${VESC_WRONG_CERT}                       %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/wrong.crt
${VESC_WRONG_KEY}                        %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/wrong.key
${VESC_OUTDATED_CERT}                    %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/outdated.crt
${VESC_OUTDATED_KEY}                     %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/outdated.key

${VESC_URL_HTTPS}                        https://%{VESC_IP}:8443
${VESC_URL}                              http://%{VESC_IP}:8080
${VES_ANY_EVENT_PATH}                    /eventListener/v5
${VES_BATCH_EVENT_PATH}             	 /eventListener/v5/eventBatch
${VES_THROTTLE_STATE_EVENT_PATH}         /eventListener/v5/clientThrottlingState
${VES_EVENTLISTENER_V7}                  /eventListener/v7
${VES_BATCH_EVENT_ENDPOINT_V7}           /eventListener/v7/eventBatch
${VES_VALID_JSON_V7}                     %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_valid.json
${VES_VALID_JSON_V7_STND_DEF_FIELDS}     %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_valid_eventWithStndDefinedFields.json
${VES_INVALID_JSON_V7}                   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_invalid.json
${VES_PARAMETER_OUT_OF_SCHEMA_V7}        %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_parameter_out_of_schema.json
${VES_MISSING_MANDATORY_PARAMETER_V7}    %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_missing_mandatory_parameter.json
${VES_EMPTY_JSON}                        %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_empty_json.json
${VES_VALID_BATCH_JSON_V7}               %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_batch_valid.json
${VES_BATCH_MISSING_MANDATORY_PARAM_V7}  %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_batch_missing_mandatory_parameter.json
${VES_BATCH_PARAM_OUT_OF_SCHEMA_V7}      %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_batch_parameter_out_of_schema.json
${EVENT_DATA_FILE}                       %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event.json
${EVENT_MEASURE_FILE}                    %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_vfirewall_measurement.json
${EVENT_DATA_FILE_BAD}                   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event_bad.json
${EVENT_BATCH_DATA_FILE}                 %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_eventlist_batch.json
${EVENT_THROTTLING_STATE_DATA_FILE}      %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_provide_throttle_state.json
${EVENT_PNF_REGISTRATION}                %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_pnf_registration_event.json
${EVENT_PNF_REGISTRATION_V7}             %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves7_pnf_registration_event.json
${DCAE_HEALTH_CHECK_BODY}                %{WORKSPACE}/tests/dcae/testcases/assets/json_events/dcae_healthcheck.json
${VES_STDN_DEFINED_EMPTY_NAMESPACE}     %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_empty_namespace.json
${VES_STDN_DEFINED_MISSING_NAMESPACE}    %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_missing_namespace.json
${VES_NAMESPACE_3GPP_PROVISIONING_MISSING_SOURCENAME}   %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_3GPP-Provisioning_missing_sourceName.json
${VES_STDN_DEFINED_3GPP_PROVISIONING}    %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_3GPP-Provisioning.json
${VES_STDN_DEFINED_3GPP_HEARTBEAT}       %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_3GPP-Heartbeat.json
${VES_STDN_DEFINED_3GPP_FAULTSUPERVISION}  %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_3GPP-FaultSupervision.json
${VES_STDN_DEFINED_3GPP_PERFORMANCE_ASSURANCE}  %{WORKSPACE}/tests/dcaegen2/testcases/assets/json_events/ves_stdnDefined_3GPP-PerformanceAssurance.json

#DCAE Health Check
${CONFIG_BINDING_URL}                    http://localhost:8443
${CB_HEALTHCHECK_PATH}                   /healthcheck
${CB_SERVICE_COMPONENT_PATH}             /service_component/
${VES_Service_Name1}                     dcae-controller-ves-collector
${VES_Service_Name2}                     ves-collector-not-exist

