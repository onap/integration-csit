*** Settings ***
Library        OperatingSystem
Library        RequestsLibrary
Library        Process

Resource    ../../resources/common-keywords.robot

*** Variables ***
${DFC_CONFIG_FILE}                         ${SIMGROUP_ROOT}/dfc_configs/c12_feed2_PM_HTTPS.yaml
${DFC_CONFIG_VOLUME_FILE}                  ${SIMGROUP_ROOT}/dfc_config_volume/application_config.yaml

*** Test Cases ***

######## Single file, HTTPS with various connections
Verify single event with single 1MB file with HTTPS connection (basic authentication). From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_40
    [Documentation]                Verify single event with single HTTPS (basic authentication) 1MB file from event poll to published file.
    ${cli_cmd_output}=              Run Process             ${DFC_ROOT}/../dfc-containers-clean.sh           stderr=STDOUT
    Verify Single Event From Event Poll To Published File   1    --tc400    HTTPS


Verify single event with single 1MB file HTTPS connection (client certificate authentication). From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_41
    [Documentation]                Verify single event with single 1MB file HTTPS connection (client certificate authentication). From event poll to published file
    Verify Single Event From Event Poll To Published File   1    --tc403    HTTPS


Verify single event with single 1MB file HTTPS (no authentication). From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_42
    [Documentation]                Verify single event with single 1MB file HTTPS (no authentication). From event poll to published file
    Verify Single Event From Event Poll To Published File   1   --tc404    HTTPS


Verify single event with single 1MB file with HTTP JWT. From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_43
    [Documentation]                Verify single event with single 1MB file with HTTP JWT. From event poll to published file
    ${cli_cmd_output}=              Run Process             ${DFC_ROOT}/../dfc-containers-clean.sh           stderr=STDOUT
    Verify Single Event From Event Poll To Published File   1    --tc303    HTTP


Verify single event with single 1MB file with HTTPS JWT. From event poll to published file
    [TAGS]                         DFC_FUNCTIONAL_44
    [Documentation]                Verify single event with single 1MB file with HTTPS JWT. From event poll to published file
    ${cli_cmd_output}=              Run Process             ${DFC_ROOT}/../dfc-containers-clean.sh           stderr=STDOUT
    Verify Single Event From Event Poll To Published File   1    --tc405    HTTPS


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

    Copy File                       ${DFC_CONFIG_FILE}                      ${DFC_CONFIG_VOLUME_FILE}
    ${dfc_config_file_content}=     Get File                                ${DFC_CONFIG_VOLUME_FILE}
    Log To Console                  APP configuration:
    Log To Console                  ${dfc_config_file_content}

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
    Set Environment Variable        HTTP_SIMS               http-https-server0:80
    Set Environment Variable        HTTPS_SIMS              http-https-server0:443
    Set Environment Variable        HTTPS_SIMS_NO_AUTH      http-https-server0:8080
    Set Environment Variable        HTTP_JWT_SIMS           http-https-server0:32000
    Set Environment Variable        HTTPS_JWT_SIMS          http-https-server0:32100
