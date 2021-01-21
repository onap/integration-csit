*** Settings ***
Library       OperatingSystem
Library       Process

*** Test Cases ***

Functional Test Case 1
    [Documentation]                 Deploy PMS without SDNC
    Start Process                   ${ARCHIVES}/test/pms_a1sim.sh
    ${cli_cmd_output}=              Wait For Process    timeout=3600
    Should Be Equal as Integers     ${cli_cmd_output.rc}    0

Functional Test Case 2
    [Documentation]                 Deploy PMS with SDNC
    Start Process                   ${ARCHIVES}/test/pms_a1sim_sdnc.sh
    ${cli_cmd_output}=              Wait For Process    timeout=3600
    Should Be Equal as Integers     ${cli_cmd_output.rc}    0
