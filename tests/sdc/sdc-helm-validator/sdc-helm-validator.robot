*** Settings ***
Documentation     Testing SDC Helm Validator
Suite Setup       Create Validator Session
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections

*** Variables ***
${VALIDATOR_URL}                    http://${VALIDATOR}
${VERSIONS_ENDPOINT}                /versions
${VALIDATE_ENDPOINT}                /validate

${CHARTS_PATH}                      %{WORKSPACE}/tests/sdc/sdc-helm-validator/assets/charts/

${CHART_CORRECT_V2}                 /correct-apiVersion-v2.tgz
${CHART_LINT_WARNING_V2}            /one-lint-warning-apiVersion-v2.tgz
${CHART_LINT_RENDER_ERROR_V2}       /one-lint-one-render-error-apiVersion-v2.tgz
${CHART_INCORRECT}                  /incorrect-chart.tgz

${REQ_KEY_VERSION_DESIRED}          versionDesired
${REQ_KEY_IS_LINTED}                isLinted
${REQ_KEY_IS_STRICT_LINTED}         isStrictLinted
${REQ_KEY_FILE}                     file

${RESP_KEY_VERSIONS}                versions
${RESP_KEY_VERSION_USED}            versionUsed
${RESP_KEY_DEPLOYABLE}              deployable
${RESP_KEY_VALID}                   valid
${RESP_KEY_RENDER_ERRORS}           renderErrors
${RESP_KEY_LINT_ERROR}              lintError
${RESP_KEY_LINT_WARNING}            lintWarning


*** Test Cases ***

Verify That Sdc Helm Validator Correctly Responds With Supported Versions Array
    [Tags]                          SDC_HELM_VALIDATOR_1
    [Documentation]                 Verify that validator correctly responds with supported helm versions array
    [Timeout]                       5 minute

    ${resp}=                        GET On Session                 ${VALIDATOR_SESSION}          ${VERSIONS_ENDPOINT}
    Status Should Be                200                            ${resp}

    ${versions}=                    Get By Key                     ${resp.json()}                ${RESP_KEY_VERSIONS}
    Should Not Be Empty             ${versions}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Default Version
    [Tags]                          SDC_HELM_VALIDATOR_2
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with default version
    [Timeout]                       5 minute

    ${chart_path}                   Catenate                       SEPARATOR=                    ${CHARTS_PATH}                    ${CHART_CORRECT_V2}
    ${files}=                       Create Multi Part              ${chart_path}

    ${resp}=                        POST On Session                ${VALIDATOR_SESSION}          ${VALIDATE_ENDPOINT}              files=${files}
    Status Should Be                200                            ${resp}

    Dictionary Should Not Contain Key  ${resp.json()}              ${RESP_KEY_LINT_ERROR}
    Dictionary Should Not Contain Key  ${resp.json()}              ${RESP_KEY_LINT_WARNING}
    Dictionary Should Not Contain Key  ${resp.json()}              ${RESP_KEY_VALID}

    ${version}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VERSION_USED}
    Should Start With               ${version}                     3.

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Be True                  ${isDeployable}

    ${errors}=                      Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Be Empty                 ${errors}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Given V3 Version
    [Tags]                          SDC_HELM_VALIDATOR_3
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with given v3 version
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_VERSION_DESIRED}=v3
    ${resp}=                        Send Post Request              ${CHART_CORRECT_V2}            ${other_data}

    Status Should Be                200                            ${resp}

    ${version}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VERSION_USED}
    Should Start With               ${version}                     3.

Verify That Sdc Helm Validator Responds With Error For Chart Validation Request With Invalid Version
    [Tags]                          SDC_HELM_VALIDATOR_4
    [Documentation]                 Verify that validator responds with error and 400 status code for validation request with invalid version
    [Timeout]                       5 minute

    ${chart_path}                   Catenate                       SEPARATOR=                    ${CHARTS_PATH}                    ${CHART_CORRECT_V2}
    ${files}=                       Create Multi Part              ${chart_path}
    ${other_data}=                  Create Dictionary              ${REQ_KEY_VERSION_DESIRED}=vBad
    ${resp}=                        Post Request                   ${VALIDATOR_SESSION}          ${VALIDATE_ENDPOINT}              files=${files}    data=${other_data}

    Should Be Equal As Strings      ${resp.status_code}            400
    Should Be Equal As Strings      ${resp.text}                   {"message":"Version: Bad is not supported"}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Random Supported Version
    [Tags]                          SDC_HELM_VALIDATOR_5
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with random supported version
    [Timeout]                       5 minute

    ${resp}=                        GET On Session                 ${VALIDATOR_SESSION}          ${VERSIONS_ENDPOINT}
    ${versions}=                    Get From Dictionary            ${resp.json()}                ${RESP_KEY_VERSIONS}
    ${list_size}=                   Get length                     ${versions}
    ${random_index}=                Evaluate                       random.randint(0, ${list_size}-1)
    ${version}=                     Get From List                  ${versions}                   ${random_index}
    Status Should Be                200                            ${resp}

    ${other_data}=                  Create Dictionary              ${REQ_KEY_VERSION_DESIRED}=${version}
    ${resp}=                        Send Post Request              ${CHART_CORRECT_V2}            ${other_data}
    Status Should Be                200                            ${resp}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Lint
    [Tags]                          SDC_HELM_VALIDATOR_6
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with lint
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_CORRECT_V2}            ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Be True                  ${isDeployable}

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Be True                  ${isValid}

    ${renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Be Empty                 ${renderErrors}

    ${lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Be Empty                 ${lintErrors}

    ${lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Be Empty                 ${lintWarnings}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Lint Warnings
    [Tags]                          SDC_HELM_VALIDATOR_7
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with lint warnings
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_LINT_WARNING_V2}      ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Be True                  ${isDeployable}

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Be True                  ${isValid}

    ${renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Be Empty                 ${renderErrors}

    ${lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Be Empty                 ${lintErrors}

    ${lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Not Be Empty             ${lintWarnings}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Lint Strict Checking
    [Tags]                          SDC_HELM_VALIDATOR_8
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with lint strict checking
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true     ${REQ_KEY_IS_STRICT_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_LINT_WARNING_V2}      ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Be True                  ${isDeployable}

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Not Be True              ${isValid}                     There should be a lint warning, which in strict mode on should make the chart invalid

    ${renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Be Empty                 ${renderErrors}

    ${lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Be Empty                 ${lintErrors}

    ${lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Not Be Empty             ${lintWarnings}

Verify That Sdc Helm Validator Correctly Responds For Chart Validation Request With Lint And Render Errors
    [Tags]                          SDC_HELM_VALIDATOR_9
    [Documentation]                 Verify that validator correctly responds for chart validation request with lint and render errors
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true     ${REQ_KEY_IS_STRICT_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_LINT_RENDER_ERROR_V2}  ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Not Be True              ${isDeployable}                There should be render errors which should make the chart not deployable

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Not Be True              ${isValid}                     There should be lint errors which should make the chart invalid

    ${renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Not Be Empty             ${renderErrors}

    ${lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Not Be Empty             ${lintErrors}

    ${lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Be Empty                 ${lintWarnings}

Verify That Sdc Helm Validator Correctly Responds For Chart Validation Request With Lint And Render Errors For Invalid Chart
    [Tags]                          SDC_HELM_VALIDATOR_10
    [Documentation]                 Verify that validator responds for chart validation request with lint and render errors for invalid chart
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true     ${REQ_KEY_IS_STRICT_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_INCORRECT}            ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Not Be True              ${isDeployable}                There should be render errors which should make the chart not deployable

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Not Be True              ${isValid}                     There should be lint errors which should make the chart invalid

    ${renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Not Be Empty             ${renderErrors}

    ${lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Not Be Empty             ${lintErrors}

    ${lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Be Empty                 ${lintWarnings}


*** Keywords ***

Create Validator Session
    Create Session                  validator_session              ${VALIDATOR_URL}
    Set Suite Variable              ${VALIDATOR_SESSION}           validator_session

Send Post Request
    [Arguments]                     ${chart_name}                  ${data_dictionary}
    ${chart_path}                   Catenate                       SEPARATOR=                    ${CHARTS_PATH}                    ${chart_name}
    ${files}=                       Create Multi Part              ${chart_path}

    ${resp}=                        POST On Session                ${VALIDATOR_SESSION}          ${VALIDATE_ENDPOINT}              files=${files}    data=${data_dictionary}
    [Return]                        ${resp}

Create Multi Part
    [Arguments]                     ${path}
    ${data}=                        Get Binary File                ${path}
    ${files}=                       Create Dictionary
    ${fileDir}  ${fileName}=        Split Path                     ${path}
    ${partData}=                    Create List                    ${fileName}                 ${data}
    Set To Dictionary               ${files}                       ${REQ_KEY_FILE}=${partData}
    [Return]                        ${files}

Get By Key
    [Arguments]                     ${dict}                        ${key}
    Dictionary Should Contain Key   ${dict}                        ${key}
    ${value}=                       Get From Dictionary            ${dict}                     ${key}
    [Return]                        ${value}
