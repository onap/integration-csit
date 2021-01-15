*** Settings ***
Library       OperatingSystem
Library       Process

*** Test Cases ***

Functional Test Case 1
    [Documentation]                 Functional Test Case 1 - FTC1
    Start Process                   ${AUTOTEST_ROOT}/CSIT_FTC1.sh    remote  docker  auto-clean  --env-file  ${TEST_ENV}   --use-snapshot-image PA SDNC  --use-release-image CP RICSIM   shell=true   cwd=${AUTOTEST_ROOT}
    ${cli_cmd_output}=              Wait For Process    timeout=3600
    Should Be Equal as Integers     ${cli_cmd_output.rc}    0
    ${ResultFileContent}=           Get File                        ${AUTOTEST_ROOT}/.resultCSIT_FTC1.txt
    Should Be Equal As Integers     ${ResultFileContent}    0

Functional Test Case 2
    [Documentation]                 Functional Test Case 2 - FTC150
    Start Process                   ${AUTOTEST_ROOT}/CSIT_FTC150.sh    remote  docker  auto-clean  --env-file  ${TEST_ENV}   --use-snapshot-image PA SDNC  --use-release-image RICSIM   shell=true   cwd=${AUTOTEST_ROOT}
    ${cli_cmd_output}=              Wait For Process    timeout=3600
    Should Be Equal as Integers     ${cli_cmd_output.rc}    0
    ${ResultFileContent}=           Get File                        ${AUTOTEST_ROOT}/.resultCSIT_FTC150.txt
    Should Be Equal As Integers     ${ResultFileContent}    0


