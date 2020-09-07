*** Settings ***
Library       OperatingSystem
Library       Process

*** Variables ***


*** Test Cases ***

Functional Test Case 1
	[Documentation]				    Functional Test Case 1 - FTC1
    Start Process                   ${AUTOTEST_ROOT}/FTC1.sh   remote  auto-clean  shell=true   cwd=${AUTOTEST_ROOT}
    ${cli_cmd_output}=              Wait For Process    timeout=3600
    Should Be Equal as Integers     ${cli_cmd_output.rc}    0
    ${ResultFileContent}=           Get File                        ${AUTOTEST_ROOT}/.resultFTC1.txt
    Should Be Equal As Integers     ${ResultFileContent}    0

*** Keywords ***



