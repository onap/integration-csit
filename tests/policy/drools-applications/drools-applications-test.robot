*** Settings ***
Library     Collections
Library     String
Library     RequestsLibrary
Library     OperatingSystem
Library     Process
Library     json

*** Test Cases ***
Alive
    [Documentation]    Runs Policy PDP Alive Check
    ${auth}=    Create List    demo@people.osaaf.org    demo123456!
    Log    Creating session https://${DROOLS_IP}:9696
    ${session}=    Create Session      policy  https://${DROOLS_IP}:9696   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   Get Request     policy  /policy/pdp/engine     headers=${headers}
    Log    Received response from policy ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings    ${resp.json()['alive']}  True

Healthcheck
    [Documentation]    Runs Policy PDP-D Health check
    ${auth}=    Create List    demo@people.osaaf.org    demo123456!
    Log    Creating session https://${DROOLS_IP}:6969/healthcheck
    ${session}=    Create Session      policy  https://${DROOLS_IP}:6969   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   Get Request     policy  /healthcheck     headers=${headers}
    Log    Received response from policy ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings    ${resp.json()['healthy']}  True

Controller
    [Documentation]    Checks controller is up
    ${auth}=    Create List    demo@people.osaaf.org    demo123456!
    Log    Creating session https://${DROOLS_IP}:9696
    ${session}=    Create Session      policy  https://${DROOLS_IP}:9696   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   Get Request     policy  /policy/pdp/engine/controllers/frankfurt/drools/facts     headers=${headers}
    Log    Received response from policy ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings    ${resp.json()['frankfurt']}  0

MakeTopics
    [Documentation]    Creates the Policy topics
    ${result}=     Run Process        ${SCR2}/make_topic.sh     POLICY-PDP-PAP
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/make_topic.sh     POLICY-CL-MGT
    Should Be Equal As Integers        ${result.rc}    0

PolicyActivate
    [Documentation]    Activates the Policies
    ${result}=     Run Process        ${SCR2}/manage.sh     ${SCR2}/policies.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/manage.sh     ${SCR2}/activate.drools.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-PDP-PAP
    ...            responseTo    drools    ACTIVE
    Log    Received status ${result.stdout}
    Sleep    3s
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    operational.restart
    Should Contain    ${result.stdout}    operational.scale.up
    Should Contain    ${result.stdout}    operational.modifyconfig

VcpeExecute
    [Documentation]    Executes VCPE Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${SCR2}/vcpeOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for APPC Restart
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for APPC Restart is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=APPC,operation=Restart
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=APPC,operation=Restart
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    APPC
    Should Contain    ${result.stdout}    Restart

VdnsExecute
    [Documentation]    Executes VDNS Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${SCR2}/vdnsOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for SO VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for SO VF Module Create is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=SO,operation=VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=SO,operation=VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    SO
    Should Contain    ${result.stdout}    VF Module Create

VfwExecute
    [Documentation]    Executes VFW Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${SCR2}/vfwOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for APPC ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for APPC ModifyConfig is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=APPC,operation=ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=APPC,operation=ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    APPC
    Should Contain    ${result.stdout}    ModifyConfig
