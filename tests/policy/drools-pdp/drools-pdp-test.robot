*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***
Alive
     [Documentation]    Runs Policy PDP Alive Check
     ${auth}=    Create List    demo@people.osaaf.org    demo123456!
     Log    Creating session https://${POLICY_DROOLS_IP}:9696
     ${session}=    Create Session      policy  https://${POLICY_DROOLS_IP}:9696   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   Get Request     policy  /policy/pdp/engine     headers=${headers}
     Log    Received response from policy ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['alive']}  True
