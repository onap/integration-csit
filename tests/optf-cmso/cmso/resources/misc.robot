*** Settings ***
Library     Collections
Library     String
#Library     UUID
Library		../attlibs/UID.py
Library     Process
Library     HttpLibrary.HTTP
Documentation     Miscellaneous keywords

Resource    json_templater.robot
Resource    create_schedule.robot


*** Variables ***

*** Keywords ***

Validate Status
    [Documentation]    Fail unless the Request response is in the passed list of valid HTTP status codes.
    [Arguments]    ${resp}    ${valid_status_list}
    ${status_code}   Convert To String   ${resp.status_code}
    Return From Keyword If   '${resp.status_code}' in ${valid_status_list}
    Fail   ${resp.status_code}
    
Validate JSON Error
    [Documentation]     Fails if messageIds do not match. expected_errors should be a list but a string would likely work as well
    [Arguments]    ${resp_json}    ${expected_errors}
    ${result}=   Get From Dictionary   ${resp_json['requestError']}   messageId   
    Should Contain    ${expected_errors}    ${result}    #checks expected_errors list for the actual error received from schedule
    
Check ATTIDs Template
   [Documentation]    This just checks a list of uuids 
   [Arguments]    ${expected_status_code}    ${template_folder}
   ${request_file}=    Convert to String    OneVnfImmediateATTID.json.template
   ${attid_file}=    OperatingSystem.Get File    robot/assets/AOTS_CM_IDs.txt
   @{attids}=    Split to lines    ${attid_file}
   :for    ${attid}    in    @{attids}
   \   ${uuid}=    Generate UUID
   \   ${resp}=   Run Keyword and Continue on Failure    Create Schedule   ${uuid}   ${request_file}   ${template_folder}    attid=${attid}
   \   Run Keyword and Continue on Failure   Should Be Equal as Strings    ${resp.status_code}    ${expected_status_code}
   \   ${reps}=   Delete Change Management   auth   schedules/${uuid}
    
    
