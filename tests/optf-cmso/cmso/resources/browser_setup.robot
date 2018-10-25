*** Settings ***
Documentation     The main interface for interacting with VID. It handles low level stuff like managing the selenium request library and VID required steps
Library           Collections
Library           OSUtils
Library           OperatingSystem
Library           Selenium2Library

*** Variables ***
${CHROME_DRIVER_WIN32_PATH}            drivers/win32
${CHROME_DRIVER_MAC64_PATH}            drivers/mac64
${CHROME_DRIVER_LINUX64_PATH}          drivers/linux64
${CHROME_DRIVER_WIN32}            ${CHROME_DRIVER_WIN32_PATH}/chromedriver.exe
${CHROME_DRIVER_MAC64}            ${CHROME_DRIVER_MAC64_PATH} /chromedriver
${CHROME_DRIVER_LINUX64}          ${CHROME_DRIVER_LINUX64_PATH}/chromedriver

*** Keywords ***
Setup Browser
    [Documentation]   Sets up browser based upon the value of 
    [Arguments]    ${browser}
    Run Keyword If    '${browser}' == 'firefox'    Setup Browser Firefox
    Run Keyword If    '${browser}' == 'chrome'    Setup Browser Chrome
    Log    Running with ${browser}
    
Setup Browser Firefox
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.FIREFOX  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1 
    Create Webdriver    Firefox    desired_capabilities=${dc}
    ##Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}
           
 
 Setup Browser Chrome
    ${os}=   Get Normalized Os 
    Log    Normalized OS=${os}
    Run Keyword If    '${os}' == 'win32'    Append To Environment Variable    PATH    ${CHROME_DRIVER_WIN32_PATH}
    ##Run Keyword If    '${os}' == 'win32'    Set Environment Variable    webdriver.chrome.driver    ${CHROME_DRIVER_WIN32}
    Run Keyword If    '${os}' == 'mac64'    Append To Environment Variable    PATH    ${CHROME_DRIVER_MAC64_PATH}
    #Run Keyword If    '${os}' == 'mac64'    Set Environment Variable  webdriver.chrome.driver    ${CHROME_DRIVER_MAC64}
    Run Keyword If    '${os}' == 'linux64'    Append To Environment Variable    PATH    ${CHROME_DRIVER_LINUX64_PATH}
    #Run Keyword if    '${os}' == 'linux64'     Set Environment Variable  webdriver.chrome.driver    ${CHROME_DRIVER_LINUX64}
    ${chrome options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome options}    add_argument    no-sandbox
    ${dc}   Evaluate    sys.modules['selenium.webdriver'].DesiredCapabilities.CHROME  sys, selenium.webdriver
    Set To Dictionary   ${dc}   elementScrollBehavior    1
    Create Webdriver    Chrome   chrome_options=${chrome_options}    desired_capabilities=${dc}  
    #Set Global Variable    ${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}    ${dc}       

Handle ATT Speed Bump    
    [Documentation]    Handle AT&T Speed Bump when accessing Rackspace UI from AT&T network
    ${test}    ${value}=    Run keyword and ignore error    Title Should Be     Notice - Uncategorized Site
    Run keyword If    '${test}' == 'PASS'    Click Element    xpath=//a[contains(@href, 'accepted-Notify-Uncategorized')] 