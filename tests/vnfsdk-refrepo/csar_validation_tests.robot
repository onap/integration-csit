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
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   PASS
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        Should Be Equal As Strings   ${resault["errors"]}   []
        Should Be Equal As Strings   ${resault["passed"]}   True
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
