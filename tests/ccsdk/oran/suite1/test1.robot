*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       Process

*** Test Cases ***
Running FTC
    [Documentation]    Check if FTC1 passes
    Run FTC1 test

*** Keywords ***
Run FTC1 test
    ${cli_cmd_output}=           Run Process          ./FTC1.sh            shell=yes
    Log To Console               ${cli_cmd_output.stdout} ${cli_cmd_output.stderr}

