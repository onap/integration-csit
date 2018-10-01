*** Settings ***
Library     keywords.py
Library     Collections

*** Variables ***
&{requestReferences}  instanceId=fffcbb6c-1983-42df-9ca8-89ae8b3a46c1  requestId=b2197d7e-3a7d-410e-82ba-7b7e8191bc46
&{entity}  requestReferences=${requestReferences}
&{expected_so_response}  status=202  entity=${entity}



*** Test Cases ***
Connection to SO is performed using HTTPS
     ${cookies}=  Login To VID
     ${response}=  Send create VF module instance request to VID  ${cookies}
     Dictionary Should Contain Item  ${response}  status  200
     Response should contain valid entity  ${response}


*** Keywords ***
