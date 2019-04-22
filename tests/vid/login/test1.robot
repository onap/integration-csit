*** Settings ***
Documentation     Logins to VID
Library 	    Selenium2Library
Library    Collections
Library         String
Library 	      RequestsLibrary
Library           OperatingSystem
Resource  ../resources/keywords/login_vid_keywords.robot

*** Test Cases ***
Login To VID GUI
    [Documentation]   Logs in to VID GUI
    # Setup Browser Now being managed by test case
    Setup Browser
    Go To    ${VID_LOGIN_URL}
    #Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}
    Log    Logging in to ${VID_ENDPOINT}${VID_ENV}
    #Handle Proxy Warning
    Title Should Be    Login
    Input Text    xpath=//input[@id='loginId']    ${GLOBAL_VID_USERNAME}
    Input Password    xpath=//input[@id='password']    ${GLOBAL_VID_PASSWORD}
    Click Button    xpath=//input[@id='loginBtn']
    Wait Until Page Contains  Welcome to VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Log    Logged in to ${VID_ENDPOINT}${VID_ENV}
    [Teardown]    Close Browser