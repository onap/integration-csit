*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       Process

*** Test Cases ***
Clone nonrtric
    [Documentation]    Cloning Non-RT RIC repo from ORAN in order to use FTC tests
    Clone

Running FTC
    [Documentation]    Check if FTC1 passes
    Run FTC1 test

*** Keywords ***
Clone
    ${cli_cmd_output}=           Run Process           ${CLONE_PATH}/clone.sh            shell=yes
    Log To Console               ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}

Run FTC1 test
    ${cli_cmd_output}=           Run Process          ${CLONE_PATH}/nonrtric/test/auto-test/FTC1.sh            shell=yes
    Log To Console               ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}