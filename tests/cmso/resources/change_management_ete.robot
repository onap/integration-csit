*** Settings ***
Documentation	  Creates VID VNF Instance

#Library   StringTemplater
#Library   UUID
Library		../attlibs/UUID.py
Library		../attlibs/StringTemplater.py
Library   Collections
Library   SSHLibrary

Resource	scheduler_common.robot
Resource	json_templater.robot
Resource	create_schedule.robot
Resource	approval_requests.robot

*** Variables ****
${TEMPLATES}	/assets/templates

*** Keywords ***
Change Management Template
   [Arguments]    ${request_file}   ${workflow}   ${minutesFromNow}=1
   ${template_folder}=    Catenate   ${TEMPLATES}/changemanagement
   ${uuid}=   Generate UUID 
   ${resp}=   Create Schedule   ${uuid}   ${request_file}   ${template_folder}   workflow=${workflow}   minutesFromNow=${minutesFromNow}   
   Should Be Equal as Strings    ${resp.status_code}    202
   Validate Acknowledgment Response Headers    ${resp} 
   Wait Until Keyword Succeeds    600s    30s    Wait For Pending Approval   ${uuid}
   Send Tier2 Approval   ${uuid}   jf9860    Accepted      
   ${resp}=   Get Change Management   auth   schedules/${uuid}
   Wait Until Keyword Succeeds    120s    30s    Wait For All VNFs Reach Status   Completed   ${uuid}
   Wait Until Keyword Succeeds    120s    30s    Wait for Schedule to Complete   Completed   ${uuid}
   ${reps}=   Delete Change Management   auth   schedules/${uuid}

Change Management Immediate Template
   [Arguments]    ${request_file}    ${workflow}  
   ${template_folder}=    Catenate   ${TEMPLATES}/changemanagement
   ${uuid}=   Generate UUID 
   ${resp}=   Create Schedule   ${uuid}   ${request_file}   ${template_folder}   workflow=${workflow}
   Should Be Equal as Strings    ${resp.status_code}   202
   Validate Acknowledgment Response Headers    ${resp}
   Wait Until Keyword Succeeds    120s    30s    Wait For All VNFs Reach Status   Completed   ${uuid}
   Wait Until Keyword Succeeds    120s    30s    Wait for Schedule to Complete   Completed   ${uuid}
   ${reps}=   Delete Change Management   auth   schedules/${uuid}
    
Wait For All VNFs Reach Status
    [Arguments]   ${status}   ${uuid}
    ${resp}=   Get Change Management   auth   schedules/scheduleDetails?request.scheduleId=${uuid}
    : for   ${vnf}   in  @{resp.json()}
    \   Dictionary Should Contain Item   ${vnf}   status   Completed 
      
Wait for Schedule to Complete
    [Arguments]   ${status}   ${uuid}
    ${resp}=   Get Change Management   auth   schedules/${uuid}
    Dictionary Should Contain Item   ${resp.json()}   status   Completed 

Create and Approve
   [Arguments]    ${request_file}   ${workflow}   ${minutesFromNow}=5  
   ${template_folder}=    Catenate   ${TEMPLATES}/changemanagement
   ${uuid}=   Generate UUID 
   ${resp}=   Create Schedule   ${uuid}   ${request_file}   ${template_folder}   workflow=${workflow}   minutesFromNow=${minutesFromNow}   
   Should Be Equal as Strings    ${resp.status_code}    202 
   Validate Acknowledgment Response Headers    ${resp}
   Wait Until Keyword Succeeds    300s    5s    Wait For Pending Approval   ${uuid}
   Send Tier2 Approval   ${uuid}   jf9860    Accepted      

Change Management Cancel Template
   [Arguments]    ${request_file}   ${workflow}   ${minutesFromNow}=5
   ${template_folder}=    Catenate   ${TEMPLATES}/changemanagement
   ${uuid}=   Generate UUID 
   ${resp}=   Create Schedule   ${uuid}   ${request_file}   ${template_folder}   workflow=${workflow}   minutesFromNow=${minutesFromNow}   
   Should Be Equal as Strings    ${resp.status_code}    202 
   Validate Acknowledgment Response Headers    ${resp}
   Wait Until Keyword Succeeds    600s    5s    Wait For Pending Approval   ${uuid}
   Send Tier2 Approval   ${uuid}   jf9860    Accepted      
   ${resp}=   Delete Change Management   auth   schedules/${uuid}
   Should Be Equal as Strings    ${resp.status_code}    204 
   Log    ${resp.headers}    
   
Validate Acknowledgment Response Headers 
    [Arguments]    ${Response} 
    Log     ${Response.headers} 
    ${act_headers_keys} =    Get Dictionary Keys    ${Response.headers} 
    Dictionary Should Contain Key    ${Response.headers}    X-LatestVersion 
    Dictionary Should Contain Key    ${Response.headers}    X-MinorVersion 
    Dictionary Should Contain Key    ${Response.headers}    X-PatchVersion
    
    
    
Change Management Immediate Template Query Data    
   [Arguments]    ${request_file}    ${workflow}  
   ${template_folder}=    Catenate   ${TEMPLATES}/SearchSchedulerDetails
   ${uuid}=   Generate UUID 
   ${resp}=   Create Schedule   ${uuid}   ${request_file}   ${template_folder}   workflow=${workflow}
   Should Be Equal as Strings    ${resp.status_code}   202
   Validate Acknowledgment Response Headers    ${resp}
   Wait Until Keyword Succeeds    120s    30s    Wait For All VNFs Reach Status   Completed   ${uuid}
   Wait Until Keyword Succeeds    120s    30s    Wait for Schedule to Complete   Completed   ${uuid}
   [Return]    ${uuid}
   
   

 
	        
