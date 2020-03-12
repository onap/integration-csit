*** Settings ***
Documentation     New VNF Change SO workflows
Library           Process
Library 	    Selenium2Library
Library    Collections
Library         String
Library 	      RequestsLibrary
Library           OperatingSystem
Resource      ../../common.robot
Resource    ../resources/keywords/login_vid_keywords.robot

*** Variables ***

*** Test Cases ***
add new VNF Change in VID GUI From SO NATIVE worfkow
    [Documentation]   create VNF Change from SO NATIVE workflows

    Run Process  ${CURDIR}/../resources/scripts/SetFeatureFlag.sh FLAG_HANDLE_SO_WORKFLOWS true  shell=True  cwd=${CURDIR}/../resources/scripts/
    Reload Page

    Wait Until Element Is Visible     xpath=//div[@heading='VNF Changes']//a[1]
    Click Element    xpath=//div[@heading='VNF Changes']//a[1]

    Click Element    xpath=//div[@ng-click='vm.createNewChange()']

    Wait Until Page Contains    New VNF Change    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}

    Select From List  xpath=//select[@name='subscriber']  CAR_2020_ER

    Select From List  xpath=//select[@name='serviceType']  gNB

    Select From List  xpath=//select[@name='vnfType']  vLBMS

    Select From List  xpath=//select[@name='fromVNFVersion']  3.0

    Click Element   xpath=//multiselect[@name='vnfName']
    Click Element   xpath=//a[contains(text(),'vnf-ws')]

    Select From List  xpath=//select[@name='workflow']  VNF In Place Software Update

    Wait Until Page Contains    Operations timeout    ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-2-operations-timeout']    10
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-3-existing-software-version']    test
    Input Text    xpath=//input[@id='internal-workflow-parameter-text-4-new-software-version']    test

    Wait Until Element Is Enabled   xpath=//button[@id='submit']  ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
    Click Button    xpath=//button[@id='submit']

    Wait Until Page Does Not Contain  New VNF Change  ${GLOBAL_SELENIUM_BROWSER_WAIT_TIMEOUT}
