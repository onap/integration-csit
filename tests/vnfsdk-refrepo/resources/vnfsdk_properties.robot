*** Variables ***
${base_url}=    http://${REFREPO_IP}:8702/onapapi/vnfsdk-marketplace/v1

${csarpath}=    ${SCRIPTS}/../tests/vnfsdk-refrepo/csar

${csar_valid_no_security}=  valid_no_security.csar
${execute_no_security_csar_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_valid_no_security}","pnf":"true"}}]

${csar_invalid_pm_dictionary}=  invalid_pm_dictionary.csar
${execute_invalid_pm_dictionary_r130206_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate-r130206","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]
${execute_invalid_pm_dictionary_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]

