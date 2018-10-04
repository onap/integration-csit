*** Settings ***
Documentation    Suite description
Resource          ./resources/common-keywords.robot

*** Test Cases ***
Check OSDF_SIM Docker Container
    [Documentation]    It checks osdf_simulator docker container is running
    Verify Docker RC Status    osdf_sim

Check OSDF Docker Container
    [Documentation]    It checks optf-osdf docker container is running
    Verify Docker RC Status    optf-osdf