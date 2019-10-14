*** Settings ***
Documentation     Collection of util keywords for managing SO simulator
Library       SeleniumLibrary
Library       RequestsLibrary
Library       OperatingSystem
Library       Collections
Library       json
Resource      ../../../common.robot


*** Keywords ***
Setup Expected Data In SO Simulator
    [Documentation]    Setup data to be returned by simulator
    [Arguments]     ${expectedResponseFilePath}   ${simulatorBaseUrl}  ${simulatorPutEndpoint}
    ${expectedDataToReturn}=  json_from_file  ${expectedResponseFilePath}
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${session}=  Create Session  so_simulator  ${simulatorBaseUrl}
    ${resp}= 	Put Request  so_simulator	uri=/${simulatorPutEndpoint}  data=${expectedDataToReturn}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200
    Log to console    Successfully initialized so-simulator: status code ${resp.status_code}


Send Post request from VID FE
    [Documentation]    Imitates VID UI. This keyword is designed for imitating calls from VID UI to VID BE
    [Arguments]    ${vidBaseUrl}  ${endpoint}  ${requestFilePath}  ${expectedResponseFilePath}  ${cookie}
    ${vidRequest}=  json_from_file  ${requestFilePath}
    ${headers}=  Create Dictionary     Content-Type=application/json  Cookie=${cookie}
    ${session}=  Create Session  vid  ${vidBaseUrl}
    ${resp}=  Post Request  vid  uri=/${endpoint}  data=${vidRequest}  headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200
    Log to console  ${resp.content}
    [Return]  ${resp}


Login to VID Internally
    [Arguments]     ${url}  ${username}    ${password}
    [Documentation]  Login using Autn
    Open browser  ${url}  chrome
    Input Text   id=loginId    ${username}
    Input Password  id=password  ${password}
    Click Element  id=loginBtn
    ${cookie}     Get Cookie    JSESSIONID
    [Return]  JSESSIONID=${cookie.value}
