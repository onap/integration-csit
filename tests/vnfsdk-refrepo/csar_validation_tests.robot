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
    ${response}=   Run   curl -s --location --request POST '${base_url}/vtp/executions' --header 'Content-Type: multipart/form-data' --header 'Accept: application/json' --form 'file=@${csarpath}/${csar_valid_no_security}' --form 'executions=${execute_no_security_csar_validation}'
    ${response}=    String.Replace String    ${response}    \\n   ${SPACE}
    # Removing strings that are causing errors during evaluation,
    # those strings are dependent on validation response and may need to be changed if vnf refrepo response changes
    ${response}=   Remove String    ${response}    \\\\    \\u003c    \\u003e   \\"
    ${json_response}=    evaluate    json.loads('''${response}''')    json
    Should Be Equal As Strings    ${json_response[0]["results"]["criteria"]}   PASS
    FOR   ${resault}  IN  @{json_response[0]["results"]["results"]}
        Should Be Equal As Strings   ${resault["errors"]}   []
        Should Be Equal As Strings   ${resault["passed"]}   True
    END
