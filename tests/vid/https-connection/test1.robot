*** Settings ***
Library     keywords.py
Library     Collections

*** Variables ***


*** Test Cases ***
Connection to SO is performed using HTTPS
     ${cookies}=  Login To VID
     ${response}=  Send create VF module instance request to VID  ${cookies}
     Dictionary Should Contain Item  ${response}  status  200
     Response should contain valid entity  ${response}


*** Keywords ***
