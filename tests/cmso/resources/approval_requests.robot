*** Settings ***
Documentation	  Scheduler keywords

#Library   StringTemplater
#Library   UUID
Library		../attlibs/UUID.py
Library		../attlibs/StringTemplater.py
Library   DateTime
Library   Collections

Resource	scheduler_common.robot
Resource	json_templater.robot

*** Variables ****
${TEMPLATES}    assets/templates/changemanagement
${UTC}   %Y-%m-%dT%H:%M:%SZ

*** Keywords ***
Wait For Pending Approval
     [Documentation]    Gets the schedule identified by the uuid and checks if it is in the Pending Approval state
     [Arguments]   ${uuid}     ${status}=Pending Approval
     ${resp}=   Get Change Management   auth   schedules/${uuid}
     ${json}=   Catenate   ${resp.json()}
     Dictionary Should Contain Item    ${resp.json()}    status    ${status}    

Send Tier2 Approval
    [Documentation]    Sends an approval post request for the given schedule using the UUID and User given and checks that request worked
    [Arguments]   ${uuid}   ${user}   ${status}
    ${approval}=   Create Dictionary   approvalUserId=${user}   approvalType=Tier 2   approvalStatus=${status}          
    ${resp}=   Post Change Management   auth   schedules/${uuid}/approvals   data=${approval}
    Should Be Equal As Strings    ${resp.status_code}   204
     
    
Send Invalid Approval    
   [Arguments]   ${uuid}   ${user}   
   ${approval}=   Create Dictionary   approvalUserId=${user}   approvalType=Tier 3   approvalStatus=Accepted              
   Run Keyword and Expect Error   400   Post Change Management   auth   schedules/${uuid}/approvals   data=${approval}
    
