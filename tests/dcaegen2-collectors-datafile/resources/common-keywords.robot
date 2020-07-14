*** Settings ***
Library		OperatingSystem
Library		RequestsLibrary
Library		Process

*** Variables ***

${CLI_MRSIM_CTR_REQUESTS}                   curl --connect-timeout 10 -X GET http://${SIM_IP}:2222/ctr_requests
${CLI_MRSIM_CTR_RESPONSES}                  curl --connect-timeout 10 -X GET http://${SIM_IP}:2222/ctr_responses
${CLI_MRSIM_CTR_FILES}                      curl --connect-timeout 10 -X GET http://${SIM_IP}:2222/ctr_unique_files

${CLI_DRSIM_CTR_QUERY_NOT_PUBLISHED}        curl --connect-timeout 10 -X GET http://${SIM_IP}:3906/ctr_publish_query_not_published
${CLI_DRSIM_CTR_PUBLISHED_FILES}            curl --connect-timeout 10 -X GET http://${SIM_IP}:3906/ctr_published_files
${CLI_DR_REDIR_SIM_DOWNLOADED_VOLUME}       curl --connect-timeout 10 -X GET http://${SIM_IP}:3908/dwl_volume

*** Keywords ***

MR Sim Emitted Files Equal
	[Documentation]				Verify that the number of emitted unique files are equal to a target value
	[Arguments]            		${target_ctr_value}
    ${resp}=					Run Process     ${CLI_MRSIM_CTR_FILES}  shell=yes
    Should Be Equal As Strings  ${resp.stdout}  ${target_ctr_value}

DR Sim Query Not Published Equal
	[Documentation]				Verify that the number responsed of queries of not published files are equal to a target value
	[Arguments]            		${target_ctr_value}
    ${resp}=					Run Process     ${CLI_DRSIM_CTR_QUERY_NOT_PUBLISHED}  shell=yes
    Should Be Equal As Strings  ${resp.stdout}  ${target_ctr_value}

DR Sim Published Files Equal
	[Documentation]				Verify that the number published files are equal to a target value
	[Arguments]            		${target_ctr_value}
    ${resp}=					Run Process     ${CLI_DRSIM_CTR_PUBLISHED_FILES}  shell=yes
    Should Be Equal As Strings  ${resp.stdout}  ${target_ctr_value}
    
DR Redir Sim Downloaded Volume Equal
	[Documentation]				Verify that the size of the downloaded data volume is equal to a target value
	[Arguments]            		${target_ctr_value}
    ${resp}=					Run Process     ${CLI_DR_REDIR_SIM_DOWNLOADED_VOLUME}  shell=yes
    Should Be Equal As Strings  ${resp.stdout}  ${target_ctr_value}

Test Teardown
	[Documentation]				Cleanup containers
    ${cli_cmd_output}=          Run Process             ${SIMGROUP_ROOT}/simulators-kill.sh
    Log To Console              ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
    ${cli_cmd_output}=          Run Process             ${DFC_ROOT}/dfc-kill.sh
    Log To Console              ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
    ${cli_cmd_output}=          Run Process             ${DFC_ROOT}/../dfc-containers-clean.sh           stderr=STDOUT
    Log To Console              Dfc containter clean: ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
