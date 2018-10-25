*** Settings ***
Documentation	  SCheduler tests

#Library   StringTemplater
#Library   UUID
Library		../attlibs/UID.py
Library		../attlibs/StringTemplater.py
Library		../attlibs/JSONUtils.py
Library   String
Library   DateTime
Library   Collections 
Library   OperatingSystem 
#Library   JSONUtils

Resource	scheduler_common.robot
Resource	json_templater.robot

*** Variables ****
${VID_TEMPLATES}    /assets/templates/changemanagement
${GLOBAL_VID_CALLBACK_URL}		http://127.0.0.1:8080/scheduler/v1/loopbacktest/vid
${GLOBAL_VID_USERID}		jf9860
${NODES}	aaiaic25ctsf0002v,dpa2bhsfe0001v,ctsf0008v,nsbg0002v
${UTC}   %Y-%m-%dT%H:%M:%SZ

*** Keywords ***
Create Schedule
    [Arguments]   ${uuid}   ${request_file}    ${TEMPLATES}   ${workflow}=Unknown    ${minutesFromNow}=5
    ${testid}=   Catenate   ${uuid}
    ${testid}=   Get Substring   ${testid}   -4
    ${dict}=   Create Dictionary   serviceInstanceId=${uuid}   parent_service_model_name=${uuid}
    ${callbackData}=   Fill JSON Template File    ${CURDIR}${VID_TEMPLATES}/VidCallbackData.json.template   ${dict} 
    ${callbackDataString}=   Json Escape    ${callbackData}   
	${map}=   Create Dictionary   uuid=${uuid}   callbackUrl=${GLOBAL_VID_CALLBACK_URL}   callbackData=${callbackDataString}    testid=${testid}   workflow=${workflow}      userId=${GLOBAL_VID_USERID}
	${nodelist}=   Split String    ${NODES}   ,
	${nn}=    Catenate    1
    # Support up to 4 ChangeWindows
    : For   ${i}   in range   1    4    
    \  ${today}=    Evaluate   ((${i}-1)*1440)+${minutesFromNow}
    \  ${tomorrow}   Evaluate   ${today}+1440 
    \  ${last_time}   Evaluate  ${today}+30   
    \  ${start_time}=    Get Current Date   UTC  + ${today} minutes   result_format=${UTC}
    \  ${end_time}=    Get Current Date   UTC   + ${tomorrow} minutes   result_format=${UTC}
    \  Set To Dictionary    ${map}   start_time${i}=${start_time}   end_time${i}=${end_time}      

	: For   ${vnf}   in    @{nodelist}
	\   Set To Dictionary    ${map}   node${nn}   ${vnf}   
	\   ${nn}=   Evaluate    ${nn}+1     

    ${data}=   Fill JSON Template File    ${CURDIR}${TEMPLATES}/${request_file}   ${map}    
    ${resp}=   Post Change Management   auth   schedules/${uuid}   data=${data}
    [Return]   ${resp}
    
       
    
