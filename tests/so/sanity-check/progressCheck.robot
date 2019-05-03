*** Settings ***
Documentation     Logins to SO-monitoring
Library   Selenium2Library
Library   String
Library   Process
Library   Collections
Library   RequestsLibrary
Library   OperatingSystem
Library   json

*** Variables ***
${GLOBAL_APPLICATION_ID}                       robot-ete
${GLOBAL_SELENIUM_BROWSER}                     chrome
${GLOBAL_SELENIUM_BROWSER_CAPABILITIES}        Create Dictionary
${GLOBAL_SELENIUM_DELAY}                       0
${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}       5
${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}        15
${SO_LOGIN_URL}                                http://so-monitoring:30224/

*** Test Cases ***

Get requestId from response from serviceInstances
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}CreateRecord.json
    ${headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5    data=${data}    headers=${headers}

    ${request_ID}=  Set Variable    ${resp.json()['requestReferences']['requestId']}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \n Execution Failure

    #Login To SO monitoring landing page
    Log   Logs into SO monitoring GUI

    #setup browser and login 
    Setup Browser
    Log    Logging in to ${SO_LOGIN_URL}
    Go To    ${SO_LOGIN_URL}    

    #Maximize Browser Window
    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}

    #Fill RequestID value in Request Id textbox and then click search and then click matching record if obtained.
    Input Text    xpath= //*[@id="mat-input-1"]  ${request_ID}
    Click Element    xpath = //*[@id="content"]/app-home/div/div[1]/button
    Click Element    xpath = //*[@id="mat-tab-content-0-0"]/div/mat-table/mat-row/mat-cell[1]/a

    #Check field values
    BuiltIn.Sleep  2
    ${startEvent}  Get Text  xpath= //*[@id="mat-tab-content-1-0"]/div/mat-table/mat-row[1]/mat-cell[1]
    Should be equal as strings    ${startEvent}    Start_WorkflowActionBB

    #click tab 2
    Click Element  xpath= //*[@id="mat-tab-label-1-1"]/div
    BuiltIn.Sleep  2
    ${requestIDinUI}  Get Text  xpath=//*[@id="mat-tab-content-1-1"]/div/mat-table/mat-row[7]/mat-cell[3]
    Should be equal as strings    ${requestIDinUI}  ${request_ID}

    [Teardown]   Close Browser


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

Setup Browser Chrome
    #${os}=   Get Normalized Os 
    #Log    Normalized OS=${os}
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

