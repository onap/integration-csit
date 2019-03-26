*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library  Process

*** Variables ***


*** Test Cases ***


Heartbeat test
    [Documentation]    Check DFC heartbeat
    Heartbeat    	   I'm living

Stop test
    [Documentation]    Check DFC stop
    Stop		   	   Datafile Service has already been stopped!

Start test
    [Documentation]    Check DFC start
    Start        	   Datafile Service has been started!

Heartbeat test - secure
    [Documentation]    Check DFC heartbeat, secure
    Heartbeat-secure   I'm living

Stop test - secure
    [Documentation]    Check DFC stop, secure
    Stop-secure   	   Datafile Service has already been stopped!


Start test - secure
    [Documentation]    Check DFC start, secure
    Start-secure       Datafile Service has been started!


#PRobably move definitions of common Keywords to a common file

*** Keywords ***
#Probably simplyfy the test cases by using variables for port numbers/urls etc
Heartbeat
    [Arguments]                  ${respbody}
    Create Session               session              http://localhost:8100/heartbeat
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}

Heartbeat-secure
    [Arguments]                  ${respbody}
    Create Session               session              https://localhost:8433/heartbeat
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}

Stop
    [Arguments]                  ${respbody}
    Create Session               session              http://localhost:8100/stopDatafile
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}

Stop-secure
    [Arguments]                  ${respbody}
    Create Session               session              https://localhost:8433/stopDatafile
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}

Start
    [Arguments]                  ${respbody}
    Create Session               session              http://localhost:8100/start
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}

Start-secure
    [Arguments]                  ${respbody}
    Create Session               session              https://localhost:8433/start
    ${resp}=                     Get Request          session                  /
    Should Be Equal				 ${resp.text}	      ${respbody}
