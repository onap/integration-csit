*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     ../../../scripts/clamp/python-lib/CustomSeleniumLibrary.py
Library     XvfbRobot

*** Variables ***
${login}                     admin
${passw}                     password
${SELENIUM_SPEED_FAST}       .2 seconds
${SELENIUM_SPEED_SLOW}       .5 seconds
${BASE_URL}                  https://localhost:8443

*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  ${BASE_URL}    auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp

*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Open Browser
# Next line is to be enabled for Headless tests only (jenkins?). To see the tests disable the line.
    Start Virtual Display    1920    1080
    Set Selenium Speed      ${SELENIUM_SPEED_SLOW}
    Open Browser    ${BASE_URL}/designer/index.html    browser=firefox

Reply to authentication popup
    Run Keyword And Ignore Error    Insert into prompt    ${login} ${passw}
    Confirm action

Good Login to Clamp UI and Verify logged in
    Set Window Size    1920    1080
    ${title}=    Get Title
    Should Be Equal    CLDS    ${title}
    Wait Until Element Is Visible       xpath=//*[@class="navbar-brand logo_name ng-binding"]       timeout=60
    Element Text Should Be      xpath=//*[@class="navbar-brand logo_name ng-binding"]       expected=Hello:admin

Open TCA1 from Menu
    Wait Until Element Is Visible       xpath=//*[@id="navbar"]/ul/li[1]/a       timeout=60
    Click Element    xpath=//*[@id="navbar"]/ul/li[1]/a
    Wait Until Element Is Visible       locator=Open CL       timeout=60
    Click Element    locator=Open CL
    Select From List By Label       id=modelName      LOOP_iYTIP_v1_0_ResourceInstanceName1_tca
    Click Button    locator=OK

Set Properties for HolmesModel1
    Wait Until Element Is Visible      xpath=//*[@data-element-id="TCA_iYTIP_v1_0_ResourceInstanceName1_tca"]       timeout=60
    Click Element    xpath=//*[@data-element-id="TCA_iYTIP_v1_0_ResourceInstanceName1_tca"]
    Wait Until Element Is Visible       xpath=//*[@id="editor"]/div/h3/div[2]/button[1]       timeout=60
    Click Element    xpath=//*[@id="editor"]/div/h3/div[2]/button[1]
    Wait Until Element Is Visible       xpath=//*[@id="root.0"]/div[2]/div/div/div[2]/div/h3/div[2]/button[1]/span      timeout=60
    Click Element    xpath=//*[@id="root.0"]/div[2]/div/div/div[2]/div/h3/div[2]/button[1]/span
    Input Text      xpath=//*[@name="root[0][metricsPerEventName][0][eventName]"]     text=Event1
    Input Text      xpath=//*[@name="root[0][metricsPerEventName][0][policyName]"]     text=PolicyScope1
    Input Text      xpath=//*[@name="root[0][metricsPerEventName][0][policyScope]"]     text=TCAPolicyScope1
    Input Text      xpath=//*[@name="root[0][metricsPerEventName][0][policyVersion]"]     text=1.2.3
    Click Button    locator=Done

Close Browser
    Close Browser
