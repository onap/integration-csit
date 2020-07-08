*** Settings ***
Documentation         This is the basic test for workflow designer
Library           RequestsLibrary
Library           Collections
Library           SeleniumLibrary
Resource          global_properties.robot

*** Variables ***
${HOMEPAGE}     http://localhost:8285
${HEADLESS}     True

***Keywords***

Open SDC GUI
    [Documentation]   Logs in to SDC GUI
    [Arguments]    ${PATH}
    ## Setup Browever now being managed by the test case
    ##Setup Browser
    Go To    ${HOMEPAGE}${PATH}
    Maximize Browser Window

    # Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    # Log    Logging in to ${SDC_FE_ENDPOINT}${PATH}
    Wait Until Page Contains    Jimmy
    # Log    Logged in to ${SDC_FE_ENDPOINT}${PATH}

Setup Browser
    [Documentation]   Sets up browser based upon the value of ${GLOBAL_SELENIUM_BROWSER}
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'firefox'    Setup Browser Firefox
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'chrome'    Setup Browser Chrome
    Log    Running with ${GLOBAL_SELENIUM_BROWSER}

Setup Browser Firefox
    ${caps}=   Evaluate   sys.modules['selenium.webdriver'].common.desired_capabilities.DesiredCapabilities.FIREFOX   sys
    Set To Dictionary   ${caps}   marionette=
    Set To Dictionary   ${caps}   elementScrollBehavior    1
    ${wd}=   Create WebDriver   Firefox   capabilities=${caps}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${caps}


Setup Browser Chrome
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome options}    add_argument    no-sandbox
    Call Method    ${chrome options}    add_argument    ignore-certificate-errors
    Run Keyword If  ${HEADLESS}==True  Call Method    ${chrome options}    add_argument    headless
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1
    Set To Dictionary   ${dc}   ACCEPT_SSL_CERTS    True
    Create Webdriver    Chrome   chrome_options=${chrome_options}    desired_capabilities=${dc}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}

Input Username
    [Arguments]       ${username}
    Input Text        name=userId    ${username}

Input Password
    [Arguments]       ${password}
    Input Text        name=password    ${password}

Input Name
    [Arguments]       ${workflowName}
    Input Text        id=workflowName    ${workflowName}

Input Description
    [Arguments]       ${description}
    Input Text        xpath=/html/body/div[2]/div/div[2]/div/form/div/div[1]/div[2]/div/textarea    ${description}

Input WFdescription
    [Arguments]       ${description}
    Input Text        xpath=//*[@id="root"]/div[1]/div/div[2]/div[2]/div/div[1]/div/textarea

Submit Login Button
    Click Element     xpath=/html/body/form/input[3]

Submit WorkFlow Button
    Click Element     xpath=/html/body/div/home-page/div/top-nav/nav/ul/li[5]/a

Add WorkFlow
    Click Element     xpath=//*[@id="root"]/div[1]/div/div[2]/div/div[2]/div[1]
    # Click Element     xpath=//*[@id="root"]/div[1]/div/div[2]/div/div[2]/div[1]/div[1]/div/svg

Create Workflow
    Click Element     xpath=/html/body/div[2]/div/div[2]/div/form/div/div[2]/button[1]

Goto Frame
    Select Frame      xpath=/html/body/div/plugin-tab-view/div/plugin-frame/div/div/iframe

Save WorkFlow
    Click Element     xpath=//*[@id="root"]/div[1]/div/div[1]/div[2]/div[2]/div/div/div[2]/div/div/span   

*** Test Cases ***
Workflow Designer Testing
    [Documentation]            User can homepage and see the tag line
    Setup Browser
    Open SDC GUI     /login
    Input Username   cs0008
    Input Password  123123a
    Submit Login Button
    Wait Until Page Contains    WORKFLOW
    Submit WorkFlow Button
    BuiltIn.Sleep  5s
    Goto Frame
    Add WorkFlow
    BuiltIn.Sleep  5s
    Input Name  testing7
    Input Description  first test through selenium
    Create Workflow
    # Wait Until Page Contains    General
    # Input Description2  write some dummy description
    # Save WorkFlow
    # BuiltIn.Sleep  5s
    Close Browser