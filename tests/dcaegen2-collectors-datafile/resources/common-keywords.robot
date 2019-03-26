*** Settings ***
Library		OperatingSystem
Library		RequestsLibrary
Library		Process

*** Variables ***

${CLI_MRSIM_CTR_REQUESTS}                  curl http://${SIM_IP}:2222/ctr_requests
${CLI_MRSIM_CTR_RESPONSES}                 curl http://${SIM_IP}:2222/ctr_responses
${CLI_MRSIM_CTR_FILES}                     curl http://${SIM_IP}:2222/ctr_unique_files

*** Keywords ***

MR Sim Emitted Files Equal
	[Documentation]				Verify that the number of emitted unique files are equal to a target value    
	[Arguments]            		${target_ctr_value}
    ${resp}=					Run Process     ${CLI_MRSIM_CTR_FILES}  shell=yes
    Should Be Equal As Strings  ${resp.stdout}  ${target_ctr_value}