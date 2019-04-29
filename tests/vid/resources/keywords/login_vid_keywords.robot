*** Settings ***
Documentation     Collection of util keywords for logging to VID
Library 	    Selenium2Library
Library    Collections
Library         String
Library 	      RequestsLibrary
Library           OperatingSystem
Resource      ../../../common.robot

*** Variables ***
${GLOBAL_APPLICATION_ID}           robot-ete
${GLOBAL_SELENIUM_BROWSER}        chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}        Create Dictionary
${GLOBAL_SELENIUM_DELAY}          0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}        5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}        25
${VID_ENV}            /vid
${VID_ENDPOINT}    http://localhost:8080
${VID_LOGIN_URL}                ${VID_ENDPOINT}${VID_ENV}/login.htm
${VID_HEALTHCHECK_PATH}    ${VID_ENV}/api/v2/users
${VID_HOME_URL}                ${VID_ENDPOINT}${VID_ENV}/welcome.htm
${GLOBAL_VID_USERNAME}        demo
${GLOBAL_VID_PASSWORD}        Kp8bJ4SXszM0WX


*** Keywords ***
Setup Browser
    [Documentation]   Sets up browser based upon the value of ${GLOBAL_SELENIUM_BROWSER}
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'firefox'    Setup Browser Firefox
    Run Keyword If    '${GLOBAL_SELENIUM_BROWSER}' == 'chrome'    Setup Browser Chrome
    Log    Running with ${GLOBAL_SELENIUM_BROWSER}

Setup Browser Firefox
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.FIREFOX  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1
    Create Webdriver    Firefox    desired_capabilities=${dc}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}

Setup Browser Chrome
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome options}    add_argument    no-sandbox
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1
    Create Webdriver    Chrome   chrome_options=${chrome_options}    desired_capabilities=${dc}
    Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}

Handle Proxy Warning
    [Documentation]    Handle Intermediate Warnings from Proxies
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    \${GLOBAL_PROXY_WARNING_TITLE}
    Return From Keyword if    '${status}' != 'PASS'
    ${status}    ${data}=    Run Keyword And Ignore Error   Variable Should Exist    \${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}
    Return From Keyword if    '${status}' != 'PASS'
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_TITLE}" == ''
    Return From Keyword if    "${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}" == ''
    ${test}    ${value}=    Run keyword and ignore error    Title Should Be     ${GLOBAL_PROXY_WARNING_TITLE}
    Run keyword If    '${test}' == 'PASS'    Click Element    xpath=${GLOBAL_PROXY_WARNING_CONTINUE_XPATH}
