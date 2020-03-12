*** Settings ***
Documentation     New VNF Change local workflows
Library           Process
Library 	    Selenium2Library
Library    Collections
Library         String
Library 	      RequestsLibrary
Library           OperatingSystem
Resource      ../../common.robot
Resource    ../resources/keywords/login_vid_keywords.robot

*** Variables ***
${body}=  {"workflowsDetails":[{"workflowName":"VNF In Place Software Update","vnfDetails":{"UUID":"103b4a1b-4a15-4559-a019-1ff132180c7c","invariantUUID":"88a71d72-ec80-4357-808e-f288823cb353"}}, {"workflowName":"VNF Scale Out","vnfDetails":{"UUID":"103b4a1b-4a15-4559-a019-1ff132180c7c","invariantUUID":"88a71d72-ec80-4357-808e-f288823cb353"}}]}

*** Test Cases ***
add new VNF Change in VID GUI From Local worfkow
    Setup Browser
    Go To    ${VID_LOGIN_URL}


    Set Selenium Speed    ${GLOBAL_SELENIUM_DELAY}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}

    Title Should Be    Login
    Input Text    xpath=//input[@id='loginId']    ${GLOBAL_VID_USERNAME}
    Input Password    xpath=//input[@id='password']    ${GLOBAL_VID_PASSWORD}
    Click Button    xpath=//input[@id='loginBtn']
    Wait Until Page Contains  Welcome to VID    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

    Run Process  ${CURDIR}/../resources/scripts/SetFeatureFlag.sh FLAG_HANDLE_SO_WORKFLOWS false  shell=True  cwd=${CURDIR}/../resources/scripts/
    Reload Page
    Wait Until Page Contains  VNF Changes    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Set Browser Implicit Wait    ${GLOBAL_SELENIUM_BROWSER_IMPLICIT_WAIT}

    [Documentation]   create VNF Change from local workflows
    CreateSession    vid    ${VID_ENDPOINT}
    ${headers}=    Create Dictionary    Accept-Encoding=gzip  Accept-Encoding=deflate    Content-Type=application/json
    ${response}=  Post Request    vid    /vid/change-management/vnf_workflow_relation    headers=${headers}  data=${body}

    Wait Until Element Is Visible     xpath=//div[@heading='VNF Changes']//a[1]
    Click Element    xpath=//div[@heading='VNF Changes']//a[1]

    Click Element    xpath=//div[@ng-click='vm.createNewChange()']

    Wait Until Page Contains    New VNF Change    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

    Select From List By Label  xpath=//select[@name='subscriber']  CAR_2020_ER

    Select From List By Label  xpath=//select[@name='serviceType']  gNB

    Select From List By Label  xpath=//select[@name='vnfType']  vLBMS

    Select From List By Label  xpath=//select[@name='fromVNFVersion']  3.0

    Click Element   xpath=//multiselect[@name='vnfName']
    Click Element   xpath=//a[contains(text(),'vnf-ws')]

    Select From List By Label  xpath=//select[@name='workflow']  VNF In Place Software Update

    Wait Until Page Contains    Operations timeout    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-2-operations-timeout']    10
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-3-existing-software-version']    test
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-4-new-software-version']    test

    Wait Until Element Is Enabled   xpath=//button[@id='submit']  ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Button    xpath=//button[@id='submit']


    Wait Until Page Does Not Contain  New VNF Change  ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}