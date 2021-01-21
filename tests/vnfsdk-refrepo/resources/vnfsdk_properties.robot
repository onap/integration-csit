*** Variables ***
${base_url}=    http://${REFREPO_IP}:8702/onapapi/vnfsdk-marketplace/v1

${csarpath}=    ${SCRIPTS}/../tests/vnfsdk-refrepo/csar

${CERTIFICATION_RULE}=  r130206
${PM_DICTIONARY_YAML_RULE}=  r816745
${MANIFEST_FILE_RULE}=  r01123
${NON_MANO_FILES_RULE}=  r146092
${OPERATION_STATUS_FAILED}=  FAILED
${OPERATION_STATUS_PASS}=  PASS

${csar_valid_no_security}=  valid_no_security.csar
${execute_no_security_csar_validation}=  [{"scenario": "onap-vtp","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_valid_no_security}","pnf":"true"}}]
${expected_valid_no_security_warnings}=  [{u'lineNumber': -1, u'message': u'Warning. Consider adding package integrity and authenticity assurance according to ETSI NFV-SOL 004 Security Option 1', u'code': u'0x1006', u'file': u'', u'vnfreqNo': u'R130206'}]

${csar_invalid_with_security}=  invalid_with_security.csar
${execute_security_csar_validation}=  [{"scenario": "onap-vtp","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_with_security}","pnf":"true"}}]
${execute_security_csar_validation_selected_rules}=  [{"scenario": "onap-vtp","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_with_security}","pnf":"true","rules":"${CERTIFICATION_RULE},${PM_DICTIONARY_YAML_RULE}"}}]

${csar_invalid_pm_dictionary}=  invalid_pm_dictionary.csar
${execute_invalid_pm_dictionary_r130206_validation}=  [{"scenario": "onap-vtp","testSuiteName": "validation","testCaseName": "csar-validate-r130206","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]
${execute_invalid_pm_dictionary_validation}=  [{"scenario": "onap-vtp","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]

