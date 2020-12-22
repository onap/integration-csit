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
${execute_no_security_csar_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_valid_no_security}","pnf":"true"}}]
${expected_valid_no_security_warnings}=  [{u'lineNumber': -1, u'message': u'Warning. Consider adding package integrity and authenticity assurance according to ETSI NFV-SOL 004 Security Option 1', u'code': u'0x1006', u'file': u'', u'vnfreqNo': u'R130206'}]

${csar_invalid_with_security}=  invalid_with_security.csar
${execute_security_csar_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_with_security}","pnf":"true"}}]
${execute_security_csar_validation_selected_rules}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_with_security}","pnf":"true","rules":"${CERTIFICATION_RULE},${PM_DICTIONARY_YAML_RULE}"}}]
${expected_manifest_file_errors}=  [{u'lineNumber': -1, u'message': u'file(s): [TOSCA-Metadata/TOSCA.meta, Definitions/MainServiceTemplate.yaml, Artifacts/Deployment/Yang_module/yang-module2.yang, Artifacts/Deployment/Yang_module/yang-module.cert, Artifacts/Deployment/Yang_module/yang-module.sig.cms, Artifacts/ChangeLog.txt, Artifacts/sample-pnf.cert] available in CSAR, but cannot be found in Manifest as Source', u'code': u'0x1001', u'file': u'TOSCA-Metadata', u'vnfreqNo': u'R01123'}]
${expected_security_errors}=  [{u'lineNumber': -1, u'message': u"Source 'Artifacts/Deployment/Measurements/PM_Dictionary.yml' has 'signature' tag, pointing to non existing file!. Pointed file 'Artifacts/Deployment/Measurements/PM_Dictionary.sig.cms'", u'code': u'0x4018', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u"Source 'Artifacts/Deployment/Yang_module/yang-module1.yang' has 'signature' file with wrong name, signature name: 'yang-module.sig.cms'.Signature should have same name as source file!", u'code': u'0x4023', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u"Source 'Artifacts/Deployment/Yang_module/yang-module1.yang' has 'certificate' file with wrong name, signature name: 'yang-module.cert'.Signature should have same name as source file!", u'code': u'0x4023', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u"Source 'Artifacts/Other/my_script.csh' has incorrect signature!", u'code': u'0x4020', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u"Source 'Artifacts/Informational/user_guide.txt' has 'signature' file located in wrong directory, directory: 'Artifacts/user_guide.sig.cms'.Signature should be in same directory as source file!", u'code': u'0x4022', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u"Source 'Artifacts/Informational/user_guide.txt' has 'certificate' file located in wrong directory, directory: 'Artifacts/user_guide.cert'.Signature should be in same directory as source file!", u'code': u'0x4022', u'vnfreqNo': u'R130206'}, {u'lineNumber': -1, u'message': u'Manifest file has invalid signature!', u'code': u'0x4007', u'file': u'', u'vnfreqNo': u'R130206'}]
${expected_non_mano_errors}=  [{u'lineNumber': -1, u'message': u'Missing. Entry [Source under onap_ves_events]', u'code': u'0x2002', u'file': u'MainServiceTemplate.mf', u'vnfreqNo': u'R146092'}, {u'lineNumber': -1, u'message': u'Missing. Entry [Source under onap_others]', u'code': u'0x2002', u'file': u'MainServiceTemplate.mf', u'vnfreqNo': u'R146092'}, {u'lineNumber': -1, u'message': u'Missing. Entry [onap_yang_module]', u'code': u'0x2002', u'file': u'MainServiceTemplate.mf', u'vnfreqNo': u'R146092'}, {u'lineNumber': -1, u'message': u'Missing. Entry [Source under onap_pm_dictionary]', u'code': u'0x2002', u'file': u'MainServiceTemplate.mf', u'vnfreqNo': u'R146092'}]
${expected_pm_dictionary_errors}=  [{u'lineNumber': -1, u'message': u'Fail to load PM_Dictionary With error: PM_Dictionary YAML file is empty', u'code': u'0x2000', u'file': u'Artifacts/Deployment/Measurements/PM_Dictionary.yml', u'vnfreqNo': u'R816745'}]

${csar_invalid_pm_dictionary}=  invalid_pm_dictionary.csar
${execute_invalid_pm_dictionary_r130206_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate-r130206","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]
${execute_invalid_pm_dictionary_validation}=  [{"scenario": "onap-dublin","testSuiteName": "validation","testCaseName": "csar-validate","parameters": {"csar": "file://${csar_invalid_pm_dictionary}","pnf":"true"}}]

