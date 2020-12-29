*** Settings ***
Library        OperatingSystem
Library        RequestsLibrary
Library        Process

Resource    ../../resources/common-keywords.robot

*** Variables ***
${CONSUL_UPL_APP}                   /usr/bin/curl -v http://127.0.0.1:8500/v1/kv/dfc_app0?dc=dc1 -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data-binary @${SIMGROUP_ROOT}/consul/c12_feed2_PM_MEAS.json
${CONSUL_GET_APP}                   /usr/bin/curl -v http://127.0.0.1:8500/v1/kv/dfc_app0?raw
${CBS_GET_MERGED_CONFIG}            /usr/bin/curl -v http://127.0.0.1:10000/service_component_all/dfc_app0

*** Test Cases ***

######## Single file, HTTP

Verify single event with single 1MB HTTP file. From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_20
    [Documentation]                Verify single event with single HTTP 1MB file from event poll to published file.
    ${cli_cmd_output}=              Run Process             ${DFC_ROOT}/../dfc-containers-clean.sh           stderr=STDOUT
    Verify Single Event From Event Poll To Published File   1    --tc300    HTTP


Verify single event with single 5MB HTTP file. From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_21
    [Documentation]                Verify single event with single HTTP 5MB file from event poll to published file.
    Verify Single Event From Event Poll To Published File   5    --tc301    HTTP


Verify single event with single 50MB HTTP file. From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_22
    [Documentation]                Verify single event with single HTTP 50MB file from event poll to published file.
    Verify Single Event From Event Poll To Published File   50   --tc302    HTTP


*** Keywords ***
Verify Single Event From Event Poll To Published File
    [Documentation]                 Keyword to verify single event with file with given parameters.
    [Arguments]                     ${file_size_in_mb}    ${mr_tc}    ${http_type}
    Set Environment Variable        MR_TC                   ${mr_tc}
    Set Environment Variable        FILE_SIZE               ${file_size_in_mb}MB
    Set Environment Variable        HTTP_TYPE                ${http_type}
    Set Default Environment Variables

    ${cli_cmd_output}=              Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
    Log To Console                  Simulator-start:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
    MR Sim Emitted Files Equal      0                                                                                   #Verify 0 file emitted from MR sim
    DR Sim Published Files Equal    0                                                                                   #Verify 0 file published to DR sim

    ${cli_cmd_output}=              Run Process                     ${CONSUL_UPL_APP}           shell=yes
    Log To Console                  Consul APP write:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}

    ${cli_cmd_output}=              Run Process                     ${CONSUL_GET_APP}           shell=yes
    Log To Console                  Consul APP read:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}

    ${cli_cmd_output}=              Run Process                     ${CBS_GET_MERGED_CONFIG}    shell=yes
    Log To Console                  CBS merged configuration:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}

    Sleep                           10

    Start DFC

    Wait Until Keyword Succeeds     1 minute      10 sec    MR Sim Emitted Files Equal          1                       #Verify 1 file emitted from MR sim
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Query Not Published Equal    1                       #Verify 1 query response for not published files
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Published Files Equal        1                       #Verify 1 file published to DR sim
    DR Redir Sim Downloaded Volume Equal          ${file_size_in_mb} 000 000                                            #Verify correct number of bytes published file data in DR redir sim

    [Teardown]                      Test Teardown

Set Default Environment Variables
    [Documentation]                 Set default environment variables for simulators setup
    Set Environment Variable        DR_TC                   --tc normal
    Set Environment Variable        DR_REDIR_TC             --tc normal
    Set Environment Variable        MR_GROUPS               OpenDcae-c12:PM_MEAS_FILES
    Set Environment Variable        MR_FILE_PREFIX_MAPPING  PM_MEAS_FILES:A
    Set Environment Variable        DR_REDIR_FEEDS          2:A
    Set Environment Variable        FTP_FILE_PREFIXES       A
    Set Environment Variable        FTP_TYPE                SFTP
    Set Environment Variable        HTTP_FILE_PREFIXES      A
    Set Environment Variable        NUM_FTPFILES            1
    Set Environment Variable        NUM_HTTPFILES           1
    Set Environment Variable        NUM_PNFS                1
    Set Environment Variable        NUM_FTP_SERVERS         1
    Set Environment Variable        NUM_HTTP_SERVERS        1
    Set Environment Variable        DR_FEEDS                2:A
    Set Environment Variable        DR_REDIR_SIM            drsim_redir
    Set Environment Variable        SFTP_SIMS               sftp-server0:22
    Set Environment Variable        FTPES_SIMS              ftpes-server-vsftpd0:21
    Set Environment Variable        HTTP_SIMS               http-server0:80
