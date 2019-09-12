*** Settings ***
Documentation     This resource is filling out json string templates and returning the json back
Library 	      RequestsLibrary
Library           StringTemplater
Library           OperatingSystem
Library           CSVLibrary
Library           Collections
Resource          global_properties.robot

*** Keywords ***
Fill JSON Template
    [Documentation]    Runs substitution on template to return a filled in json
    [Arguments]    ${json}    ${arguments}
    ${returned_string}=    Template String    ${json}    ${arguments}
    Log    ${returned_string}
    ${returned_json}=  To Json    ${returned_string}
    [Return]    ${returned_json}

Fill JSON Template File
    [Documentation]    Runs substitution on template to return a filled in json
    [Arguments]    ${json_file}    ${arguments}
    ${json}=    OperatingSystem.Get File    ${json_file}
    ${returned_json}=  Fill JSON Template    ${json}    ${arguments}
    [Return]    ${returned_json}
    
Read CSV Data And Create Dictionary
    [Documentation]    Read CSV Data And Create Dictionary
    [Arguments]        ${file}

     ${status}    Run Keyword And Return Status    Variable Should Exist    ${file}
     ${csv_file} =     set variable if  ${status}==True    ${file}
     LOG    ${csv_file}
     ${dictionary}    Create Dictionary
     ${dictionary_list}    read csv file to associative  ${csv_file}

     ${dict_count}    Get Length    ${dictionary_list}
     : FOR    ${row_num}    IN RANGE    0    ${dict_count}
     \    Log    ${dictionary_list[${row_num}]}
     \    ${dict_key}    Get From Dictionary    ${dictionary_list[${row_num}]}    uniqueKey
     \    Set To Dictionary    ${dictionary}    ${dict_key}    ${dictionary_list[${row_num}]}

     [Return]    ${dictionary}