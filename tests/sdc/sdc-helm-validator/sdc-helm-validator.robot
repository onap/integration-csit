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
    [Tags]                          SDC_HELM_VALIDATOR_1    VERSIONS_ENDPOINT
    [Documentation]                 Verify that validator correctly responds with supported helm versions array.
    ...                             Send GET request to ask for supported versions array.
    ...                             Should reply with JSON containing an array of Helm versions that are supported by the validator.
    [Timeout]                       5 minute

    ${resp}=                        GET On Session                 ${VALIDATOR_SESSION}          ${VERSIONS_ENDPOINT}
    Status Should Be                200                            ${resp}

    @{versions}=                    Get From Dictionary            ${resp.json()}                ${RESP_KEY_VERSIONS}
    Should Not Be Empty             ${versions}

    FOR                             ${version}                     IN                            @{versions}
                                    Should Match Regexp            ${version}                    \\d+\.\\d+\.\\d+
    END

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Default Version
    [Tags]                          SDC_HELM_VALIDATOR_2    VALIDATE_ENDPOINT    DEPLOYABLE
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with default version.
    ...                             Send POST request to validate correct chart. Input: Helm chart with api version v2, no additional data.
    ...                             Should reply with JSON containing the following information: used version = 3.x.x, deployable = true, render errors = []
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary
    ${resp}=                        Send Post Request              ${CHART_CORRECT_V2}            ${other_data}

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
    [Tags]                          SDC_HELM_VALIDATOR_3    VALIDATE_ENDPOINT    DEPLOYABLE
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with given v3 version.
    ...                             Send POST request to validate correct chart. Input: Helm chart with api version v2, desired version = v3.
    ...                             Should reply with JSON containing the following information: used version = 3.x.x, deployable = true, render errors = [].
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_VERSION_DESIRED}=v3
    ${resp}=                        Send Post Request              ${CHART_CORRECT_V2}            ${other_data}

    Status Should Be                200                            ${resp}

    ${version}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VERSION_USED}
    Should Start With               ${version}                     3.

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Be True                  ${isDeployable}

    ${errors}=                      Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Be Empty                 ${errors}

Verify That Sdc Helm Validator Responds With Error For Chart Validation Request With Invalid Version
    [Tags]                          SDC_HELM_VALIDATOR_4    VALIDATE_ENDPOINT    ERROR
    [Documentation]                 Verify that validator responds with error and 400 status code for validation request with invalid version.
    ...                             Send POST request with correct chart but not supported Helm version. Input: Correct helm chart, desired version = v10.
    ...                             Should reply with JSON containing error message with information regarding not supported Helm version. Response code should be 400.
    [Timeout]                       5 minute

    ${chart_path}                   Catenate                       SEPARATOR=                    ${CHARTS_PATH}                    ${CHART_CORRECT_V2}
    ${files}=                       Create Multi Part              ${chart_path}
    ${other_data}=                  Create Dictionary              ${REQ_KEY_VERSION_DESIRED}=v10
    ${resp}=                        Post Request                   ${VALIDATOR_SESSION}          ${VALIDATE_ENDPOINT}              files=${files}    data=${other_data}

    Should Be Equal As Strings      ${resp.status_code}            400
    Should Be Equal As Strings      ${resp.text}                   {"message":"Version: 10 is not supported"}

Verify That Sdc Helm Validator Correctly Responds For Correct Chart Validation Request With Random Supported Version
    [Tags]                          SDC_HELM_VALIDATOR_5    VERSIONS_ENDPOINT    VALIDATE_ENDPOINT
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with random supported version.
    ...                             Send GET request to ask for supported versions array.
    ...                             Should reply with JSON containing an array of Helm versions that are supported by the validator.
    ...                             Select random version from the returned array.
    ...                             Send POST request with correct chart and randomly chosen supported Helm version. Input: Correct helm chart, desired version = [randomly selected].
    ...                             Response code should be 200.
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
    [Tags]                          SDC_HELM_VALIDATOR_6    VALIDATE_ENDPOINT    LINT    DEPLOYABLE    VALID
    [Documentation]                 Verify that validator correctly responds for correct chart validation request with lint.
    ...                             Send POST request to validate correct chart and lint. Input: Helm chart with api version v2, linted = true.
    ...                             Should reply with JSON containing the following information: deployable = true, valid = true, render errors = [], lint errors = [], lint warnings = [].
    ...                             Status code should be 200.
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

Verify That Sdc Helm Validator Correctly Responds For Chart Validation Request With Lint Warnings
    [Tags]                          SDC_HELM_VALIDATOR_7    VALIDATE_ENDPOINT    LINT    DEPLOYABLE    VALID
    [Documentation]                 Verify that validator correctly responds for chart validation request with lint warnings.
    ...                             Send POST request to validate chart and lint. Input: Helm chart that should cause lint warning, linted = true.
    ...                             Should reply with JSON containing the following information: deployable = true, valid = true, render errors = [], lint warning = [not empty]
    ...                             Status code should be 200.
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

    @{lintWarnings}=                Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_WARNING}
    Should Not Be Empty             @{lintWarnings}
    Should Contain                  @{lintWarnings}                [WARNING] templates/: directory not found

Verify That Sdc Helm Validator Correctly Responds For Chart Validation Request With Lint Strict Checking
    [Tags]                          SDC_HELM_VALIDATOR_8    VALIDATE_ENDPOINT    STRICT_LINT    DEPLOYABLE    NON_VALID
    [Documentation]                 Verify that validator correctly responds for chart validation request with lint strict checking.
    ...                             Send POST request to validate chart and strictly lint. Input: Helm chart that should cause lint warning, linted = true, strict linted = true.
    ...                             Should reply with JSON containing the following information: deployable = true, valid = false, render errors = [], lint warning = [not empty].
    ...                             Status code should be 200.
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
    Should Contain                  @{lintWarnings}                [WARNING] templates/: directory not found

Verify That Sdc Helm Validator Correctly Responds For Chart Validation Request With Lint And Render Errors
    [Tags]                          SDC_HELM_VALIDATOR_9    VALIDATE_ENDPOINT    STRICT_LINT    NON_DEPLOYABLE    NON_VALID
    [Documentation]                 Verify that validator correctly responds for chart validation request with lint and render errors.
    ...                             Send POST request to validate chart and strictly lint. Input: Helm chart that should cause lint and render errors, linted = true, strict linted = true.
    ...                             Should reply with JSON containing the following information: deployable = false, valid = false, render errors = [not empty], lint errors = [not empty], lint warnings = [].
    ...                             Status code should be 200.
    [Timeout]                       5 minute

    ${other_data}=                  Create Dictionary              ${REQ_KEY_IS_LINTED}=true     ${REQ_KEY_IS_STRICT_LINTED}=true
    ${resp}=                        Send Post Request              ${CHART_LINT_RENDER_ERROR_V2}  ${other_data}
    Status Should Be                200                            ${resp}

    ${isDeployable}=                Get By Key                     ${resp.json()}                ${RESP_KEY_DEPLOYABLE}
    Should Not Be True              ${isDeployable}                There should be render errors which should make the chart not deployable

    ${isValid}=                     Get By Key                     ${resp.json()}                ${RESP_KEY_VALID}
    Should Not Be True              ${isValid}                     There should be lint errors which should make the chart invalid

    @{renderErrors}=                Get By Key                     ${resp.json()}                ${RESP_KEY_RENDER_ERRORS}
    Should Not Be Empty             @{renderErrors}
    Should Contain                  @{renderErrors}                Error: template: mychartname/templates/test.yaml:2:18: executing "mychartname/templates/test.yaml" at <.Values.image.repository>: nil pointer evaluating interface {}.repository

    @{lintErrors}=                  Get By Key                     ${resp.json()}                ${RESP_KEY_LINT_ERROR}
    Should Not Be Empty             @{lintErrors}
    Should Contain                  @{lintErrors}                  [ERROR] templates/: template: mychartname/templates/test.yaml:2:18: executing "mychartname/templates/test.yaml" at <.Values.image.repository>: nil pointer evaluating interface {}.repository

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
