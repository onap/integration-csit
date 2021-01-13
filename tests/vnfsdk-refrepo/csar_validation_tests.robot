*** Settings ***
Resource          ./resources/vnfsdk_keywords.robot

*** Test Cases ***

Perform vnf refrepo healthcheck
    [Documentation]    Check if vnf refrepo is up and running

    Create Session   refrepo  ${base_url}
    ${response}=    Get Request    refrepo   /PackageResource/healthcheck
    Should Be Equal As Strings  ${response.status_code}     200

Validate correct, no security CSAR
    [Documentation]    Valid CSAR with no security should PASS validation and should return no error

    ${response}=   Validate CSAR usign Post request   ${csar_valid_no_security}   ${execute_no_security_csar_validation}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   ${OPERATION_STATUS_PASS}
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        Should Be Equal As Strings   ${resault["errors"]}   []
        Should Be Equal As Strings   ${resault["passed"]}   True
        run keyword if  "${resault["vnfreqName"]}" == "${CERTIFICATION_RULE}"
        ...  Should Be Equal As Strings   ${resault["warnings"]}   ${expected_valid_no_security_warnings}
    END


Validate secure CSAR with invalid certificate
    [Documentation]    Valid CSAR with cms signature in manifest file and certificate in TOSCA, containing individual signatures for multiple artifacts, using common certificate and individual certificate

    ${response}=   Validate CSAR usign Post request   ${csar_invalid_with_security}   ${execute_security_csar_validation}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   ${OPERATION_STATUS_FAILED}
    ${validated_rules}=  Get Length  ${json_response[0]["results"]["results"]}
    Should Be Equal As Strings  ${validated_rules}  14
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        ${validation_errors}=  Get Length  ${resault["errors"]}
        run keyword if  "${resault["vnfreqName"]}" == "${CERTIFICATION_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  9
        run keyword if  "${resault["vnfreqName"]}" == "${PM_DICTIONARY_YAML_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  1
        run keyword if  "${resault["vnfreqName"]}" == "${MANIFEST_FILE_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  1
        run keyword if  "${resault["vnfreqName"]}" == "${NON_MANO_FILES_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  4
    END


Validate CSAR using selected rules
    [Documentation]    Valid CSAR using only selected rules provided in request parameters

    ${response}=   Validate CSAR usign Post request   ${csar_invalid_with_security}   ${execute_security_csar_validation_selected_rules}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   ${OPERATION_STATUS_FAILED}
     ${validated_rules}=  Get Length  ${json_response[0]["results"]["results"]}
    Should Be Equal As Strings  ${validated_rules}  3
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        ${validation_errors}=  Get Length  ${resault["errors"]}
        run keyword if  "${resault["vnfreqName"]}" == "${CERTIFICATION_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  9
        run keyword if  "${resault["vnfreqName"]}" == "${PM_DICTIONARY_YAML_RULE}"
        ...  Should Be Equal As Strings  ${validation_errors}  1
    END



Validate CSAR using rule r130206 and use get method to receive outcome
    [Documentation]    Validate CSAR with invalid PM_Dictionary (r130206)  using rule r130206 , then use get method with validation id to receive valdiation outcome

    ${response}=   Validate CSAR usign Post request   ${csar_invalid_pm_dictionary}   ${execute_invalid_pm_dictionary_r130206_validation}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json

    ${get_response}=   Get validation result using GET request    ${json_response[0]["executionId"]}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${get_response}=   Remove String    ${get_response}    \\\\    \\u0027
    ${json_get_response}=    evaluate    json.loads('''${get_response}''')    json
    Should Be Equal As Strings   ${json_get_response[0]["status"]}   failed
    ${errors_number}=    Get Length    ${json_get_response[0]["results"]}
    Should Be Equal As Strings  ${errors_number}  4
    FOR   ${error}  IN  @{json_get_response[0]["results"]}
        Should Contain   ${error["code"]}  R130206
    END

Validate CSAR using all rule and use get method to receive outcome
    [Documentation]    Validate CSAR with invalid PM_Dictionary (r130206) using all rules, then use get method with validation id to receive valdiation outcome

    ${response}=   Validate CSAR usign Post request   ${csar_invalid_pm_dictionary}   ${execute_invalid_pm_dictionary_validation}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json

    ${get_response}=   Get validation result using GET request    ${json_response[0]["executionId"]}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${get_response}=   Remove String    ${get_response}    \\\\    \\u0027   \\u003c    \\u003e   \\"
    ${json_get_response}=    evaluate    json.loads('''${get_response}''')    json
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   FAILED
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        Should Be Equal As Strings   ${resault["warnings"]}   []
        Run keyword if   "${resault["vnfreqName"]}" == "r130206"
        ...   Should Be Equal As Strings   ${resault["passed"]}   False
    END
