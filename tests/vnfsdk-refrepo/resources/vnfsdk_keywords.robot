*** Settings ***
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           RequestsLibrary
Library           json

*** Variables ***
${base_url}=    http://${REFREPO_IP}:8702/onapapi/vnfsdk-marketplace/v1

${csarpath}=    ${SCRIPTS}/../tests/vnfsdk-refrepo/csar

${csar_valid_no_security}=  valid_no_security.csar
${execute_no_security_csar_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_valid_no_security}","pnf":"true"}}]
