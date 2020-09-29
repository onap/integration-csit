*** Settings ***
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           RequestsLibrary
Library           json


*** Variables ***
${base_url}=    http://${REFREPO_IP}:8702/onapapi/vnfsdk-marketplace/v1

*** Test Cases ***
Perform vnf refrepo healthcheck
    [Documentation]    Check if vnf refrepo is up and running
    Create Session   refrepo  ${base_url}
    ${response}=    Get Request    refrepo   /PackageResource/healthcheck
    Should Be Equal As Strings  ${response.status_code}     200
