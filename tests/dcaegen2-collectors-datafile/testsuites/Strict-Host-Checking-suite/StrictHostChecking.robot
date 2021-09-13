*** Settings ***
Library        OperatingSystem
Library        RequestsLibrary
Library        Process

Resource    ../../resources/common-keywords.robot

Test Teardown

*** Variables ***
${DFC_CONFIG_FILE}                         ${SIMGROUP_ROOT}/dfc_configs/c12_feed2_PM_MEAS.yaml
${DFC_CONFIG_FILE_INSECURE_SFTP}           ${SIMGROUP_ROOT}/dfc_configs/c12_feed2_PM_MEAS_no_strict_host_key_checking.yaml

*** Test Cases ***

######### Single file, SFTP, various SFTP Strict host key checking settings

Verify single event with SFTP file, when host known and strict host key checking enabled. From event poll to published file
    [TAGS]                          DFC_STRICT_HOST_KEY_CHECKING_1
    [Documentation]                 Verify single event with SFTP file, when host known and strict host key checking enabled. From event poll to published file.
    [Setup]  Setup Strict Host Key Checking Test  ${DFC_CONFIG_FILE}  all_hosts_keys

    Wait Until Keyword Succeeds     1 minute      10 sec    MR Sim Emitted Files Equal          1                       #Verify 1 file emitted from MR sim
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Query Not Published Equal    1                       #Verify 1 query response for not published files
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Published Files Equal        1                       #Verify 1 file published to DR sim
    DR Redir Sim Downloaded Volume Equal          1 000 000                                                             #Verify 1 000 000 bytes published file data in DR redir sim

    [Teardown]                      Test Teardown

Verify single event with SFTP file, when host unknown and strict host key checking disabled. From event poll to published file
    [TAGS]                          DFC_STRICT_HOST_KEY_CHECKING_2
    [Documentation]                 Verify single event with SFTP file, when host unknown and strict host key checking disabled. From event poll to published file.
    [Setup]  Setup Strict Host Key Checking Test  ${DFC_CONFIG_FILE_INSECURE_SFTP}  known_hosts_empty

    Wait Until Keyword Succeeds     1 minute      10 sec    MR Sim Emitted Files Equal          1                       #Verify 1 file emitted from MR sim
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Query Not Published Equal    1                       #Verify 1 query response for not published files
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Published Files Equal        1                       #Verify 1 file published to DR sim
    DR Redir Sim Downloaded Volume Equal          1 000 000                                                             #Verify 1 000 000 bytes published file data in DR redir sim

    [Teardown]                      Test Teardown

Verify single event with SFTP file, when no known hosts file and strict host key checking enabled. From event poll to published file
    [TAGS]                          DFC_STRICT_HOST_KEY_CHECKING_3
    [Documentation]                 Verify single event with SFTP file, when host unknown and strict host key checking enabled. File not published.
    [Setup]  Setup Strict Host Key Checking Test  ${DFC_CONFIG_FILE}  no_known_hosts_file

    Wait Until Keyword Succeeds     1 minute      10 sec    MR Sim Emitted Files Equal          1                       #Verify 1 file emitted from MR sim
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Query Not Published Equal    1                       #Verify 1 query response for not published files
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Published Files Equal        1                       #Verify 1 file published to DR sim
    DR Redir Sim Downloaded Volume Equal          1 000 000                                                             #Verify 1 000 000 bytes published file data in DR redir sim

    [Teardown]                      Test Teardown



Verify single event with SFTP file, when host unknown and strict host key checking enabled. File not published
    [TAGS]                          DFC_STRICT_HOST_KEY_CHECKING_4
    [Documentation]                 Verify single event with SFTP file, when host unknown and strict host key checking enabled. File not published.
    [Setup]  Setup Strict Host Key Checking Test  ${DFC_CONFIG_FILE}  known_hosts_empty
    Wait Until Keyword Succeeds     1 minute      10 sec    MR Sim Emitted Files Equal          1                       #Verify 1 file emitted from MR sim
    Wait Until Keyword Succeeds     1 minute      10 sec    DR Sim Query Not Published Equal    1                       #Verify 1 query response for not published files
    Sleep                           60
    DR Sim Published Files Equal    0                                                                                   #Verify no file was published to DR sim
    [Teardown]                      Test Teardown

*** Keywords ***

Setup Strict Host Key Checking Test
    [Documentation]                 Sets up strict host key checking test with single 1MB file
    [Arguments]                     ${dfc_config_path}  ${known_hosts_file}
    Set Environment Variable        MR_TC                   --tc100
    Set Environment Variable        DR_TC                   --tc normal
    Set Environment Variable        DR_REDIR_TC             --tc normal
    Set Environment Variable        MR_GROUPS               OpenDcae-c12:PM_MEAS_FILES
    Set Environment Variable        MR_FILE_PREFIX_MAPPING  PM_MEAS_FILES:A
    Set Environment Variable        DR_REDIR_FEEDS          2:A
    Set Environment Variable        FTP_FILE_PREFIXES       A
    Set Environment Variable        HTTP_FILE_PREFIXES      A
    Set Environment Variable        NUM_FTPFILES            1
    Set Environment Variable        NUM_HTTPFILES           1
    Set Environment Variable        NUM_PNFS                1
    Set Environment Variable        FILE_SIZE               1MB
    Set Environment Variable        FTP_TYPE                SFTP
    Set Environment Variable        HTTP_TYPE               HTTP
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

    ${cli_cmd_output}=              Run Process     ./simulators-start.sh    cwd=${SIMGROUP_ROOT}
    Log To Console                  Simulator-start:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
    MR Sim Emitted Files Equal      0                                                                                   #Verify 0 file emitted from MR sim
    DR Sim Published Files Equal    0                                                                                   #Verify 0 file published to DR sim

    Set DFC config                  ${dfc_config_path}

    ${cli_cmd_output}=              Run Process                    ${DFC_ROOT}/dfc-start.sh    cwd=${DFC_ROOT}    env:KNOWN_HOSTS=${known_hosts_file}    env:SIMGROUP_ROOT=${SIMGROUP_ROOT}
    Log To Console                  Dfc-start:
    Log To Console                  ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}
