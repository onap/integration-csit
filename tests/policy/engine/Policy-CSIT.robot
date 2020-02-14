*** Settings ***
Documentation	  Policy ONAP CSIT Test cases
Library    String
Library    HttpLibrary.HTTP
LIbrary    Process
Library    BuiltIn
Library    ONAPLibrary.Templating
Resource    policy_interface.robot

*** Variables ***
${RESOURCE_PATH_CREATE}        /pdp/api/createPolicy
${RESOURCE_PATH_CREATE_PUSH}        /pdp/api/pushPolicy
${RESOURCE_PATH_CREATE_DELETE}        /pdp/api/deletePolicy
${RESOURCE_PATH_GET_CONFIG}    /pdp/api/getConfig
${RESOURCE_PATH_LISTPOLICY}        /pdp/api/listPolicy
${CREATE_CONFIG_VFW_TEMPLATE}    configpolicy_vFW_R1.jinja
${CREATE_CONFIG_VDNS_TEMPLATE}    configpolicy_vDNS_R1.jinja
${CREATE_CONFIG_VCPE_TEMPLATE}    configpolicy_vCPE_R1.jinja
${CREATE_OPS_VFW_TEMPLATE}    opspolicy_VFW_R1.jinja
${CREATE_OOF_HPA_TEMPLATE}    oofpolicy_HPA_R1.jinja
${CREATE_SDNC_VFW_TEMPLATE}     sdncnamingpolicy_vFW.jinja
${CREATE_SDNC_VPG_TEMPLATE}     sdncnamingpolicy_vPG.jinja
${PUSH_POLICY_TEMPLATE}   pushpolicy.jinja
${MULTIPLE_PUSH_POLICY_TEMPLATE}   multiple_pushpolicy.jinja
${MULTIPLE_UNPUSH_POLICY_TEMPLATE}   multiple_unpushpolicy.jinja
${CREATE_OPS_VDNS_TEMPLATE}    opspolicy_VDNS_R1.jinja
${DEL_POLICY_TEMPLATE}   deletepolicy.jinja
${GETCONFIG_TEMPLATE}    getconfigpolicy.jinja
${GETOOF_TEMPLATE}       getoofpolicy.jinja
${LISTPOLICY_TEMPLATE}    listpolicy.jinja
${CONFIG_POLICY_VFW_NAME}    vFirewall
${CONFIG_POLICY_VFW_TYPE}    MicroService
${CONFIG_POLICY_VDNS_NAME}    vLoadBalancer
${CONFIG_POLICY_VDNS_TYPE}    MicroService
${OPS_POLICY_VFW_NAME}    vFirewall
${OPS_POLICY_VFW_TYPE}    BRMS_PARAM
${OPS_POLICY_VDNS_NAME}    vLoadBalancer
${OPS_POLICY_VDNS_TYPE}    BRMS_PARAM
${CONFIG_POLICY_VCPE_NAME}    vCPE
${CONFIG_POLICY_VCPE_TYPE}    MicroService
${OPS_POLICY_VCPE_NAME}    vCPE
${OPS_POLICY_VCPE_TYPE}    BRMS_PARAM
${OPS_POLICY_VOLTE_NAME}    VoLTE
${OPS_POLICY_VOLTE_TYPE}    BRMS_PARAM
${OOF_POLICY_HPA_NAME}    HPA
${OOF_POLICY_HPA_TYPE}    Optimization 
${SDNC_POLICY_VFW_NAME}   ONAP_vFW_Naming
${SDNC_POLICY_VPG_NAME}   ONAP_vPG_Naming
${MULTIPLE_PUSH_POLICY_NAME1}   com.testBase1
${MULTIPLE_PUSH_POLICY_NAME2}   com.testBase2
${MULTIPLE_PUSH_POLICY_NAME3}   com.testBase3
${file_path}        ../testsuite/robot/assets/templates/ControlLoopDemo__closedLoopControlName.drl
${RESOURCE_PATH_UPLOAD}  /pdp/api/policyEngineImport?importParametersJson=%7B%22serviceName%22%3A%22Manyu456%22%2C%20%22serviceType%22%3A%22BRMSPARAM%22%7D
${CREATE_OPS_VCPE_TEMPLATE}      opspolicy_vCPE_R1.jinja 
${CREATE_OPS_VOLTE_TEMPLATE}    opspolicy_vOLTE_R1.jinja


*** Test Cases ***
VFW Config Policy
    ${CONFIG_POLICY_VFW_NAME}=    Create Config VFW Policy
    Push Config Policy    ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}  
    #VFW Policy Tests
    
VDNS Config Policy
    ${CONFIG_POLICY_VDNS_NAME}=    Create Config VDNS Policy
    Push Config Policy    ${CONFIG_POLICY_VDNS_NAME}    ${CONFIG_POLICY_VDNS_TYPE}
    #VDNS Policy Tests 
    
VCPE Config Policy
    ${CONFIG_POLICY_VCPE_NAME}=    Create Config VCPE Policy
    Push Config Policy    ${CONFIG_POLICY_VCPE_NAME}    ${CONFIG_POLICY_VCPE_TYPE}
    #VCPE Policy Tests

VFW Ops Policy
     ${OPS_POLICY_VFW_NAME}=    Create Ops VFW Policy
     Push Ops Policy    ${OPS_POLICY_VFW_NAME}    ${OPS_POLICY_VFW_TYPE}
     
VDNS Ops Policy
     ${OPS_POLICY_VDNS_NAME}=    Create Ops VDNS Policy
     Push Ops Policy    ${OPS_POLICY_VDNS_NAME}    ${OPS_POLICY_VDNS_TYPE}    
     
VCPE Ops Policy
     ${OPS_POLICY_VCPE_NAME}=    Create Ops VCPE Policy
     Push Ops Policy    ${OPS_POLICY_VCPE_NAME}    ${OPS_POLICY_VCPE_TYPE}    

VOLTE Ops Policy
     ${OPS_POLICY_VOLTE_NAME}=    Create Ops VOLTE Policy
     Push Ops Policy    ${OPS_POLICY_VOLTE_NAME}    ${OPS_POLICY_VOLTE_TYPE}    
    #VOLTE Policy Tests

VFW SDNC Naming Policy
     ${SDNC_POLICY_VFW_NAME}=    Create VFW SDNC Naming Policy
     Push Config Policy    ${SDNC_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
    #VFW Policy Tests
    
VPG SDNC Naming Policy
     ${SDNC_POLICY_VPG_NAME}=    Create VPG SDNC Naming Policy
     Push Config Policy    ${SDNC_POLICY_VPG_NAME}    ${CONFIG_POLICY_VFW_TYPE}
    #VPG Policy Tests

HPA OOF Policy
     ${OOF_POLICY_HPA_NAME}=     Create OOF HPA Policy
     Push Config Policy    ${OOF_POLICY_HPA_NAME}      ${OOF_POLICY_HPA_TYPE}
    #HPA Policy Tests
 
VFW Get Configs Policy
    Sleep    5s
    Get Configs VFW Policy 
    
VDNS Get Configs Policy
    Sleep    5s
    Get Configs VDNS Policy 
    
VCPE Get Configs Policy
    Sleep    5s
    Get Configs VCPE Policy 
    
HPA Get OOF Policy
    Sleep    5s
    Get OOF HPA Policy

ListPolicy
    ListPolicy test    com.Config_Sample.1.xml

Multiple Push Policy
    ${MULTIPLE_PUSH_POLICY_NAME1}=    Create Ops VDNS Policy
    ${MULTIPLE_PUSH_POLICY_NAME2}=    Create Ops VDNS Policy
    ${MULTIPLE_PUSH_POLICY_NAME3}=    Create Ops VDNS Policy
    Push Multiple Policy test    ${MULTIPLE_PUSH_POLICY_NAME1}	${MULTIPLE_PUSH_POLICY_NAME2}	${MULTIPLE_PUSH_POLICY_NAME3}      ${OPS_POLICY_VDNS_TYPE}
    Sleep    5s
    Delete Multiple Policy test    ${MULTIPLE_PUSH_POLICY_NAME1}	${MULTIPLE_PUSH_POLICY_NAME2}	${MULTIPLE_PUSH_POLICY_NAME3}      ${OPS_POLICY_VDNS_TYPE}

*** Keywords ***

VFW Policy Tests
     ${CONFIG_POLICY_VFW_NAME}=    Create Config VFW Policy
     Push Config Policy    ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
     Get Configs VFW Policy    
     ${OPS_POLICY_VFW_NAME}=    Create Ops VFW Policy
     Push Ops Policy    ${OPS_POLICY_VFW_NAME}    ${OPS_POLICY_VFW_TYPE}
     ${SDNC_POLICY_VFW_NAME}=   Create VFW SDNC Naming Policy
     Push Config Policy     ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
    
VDNS Policy Tests
     ${CONFIG_POLICY_VDNS_NAME}=    Create Config VDNS Policy
     Push Config Policy    ${CONFIG_POLICY_VDNS_NAME}    ${CONFIG_POLICY_VDNS_TYPE}
     Get Configs VDNS Policy
     ${OPS_POLICY_VDNS_NAME}=    Create Ops VDNS Policy
     Push Ops Policy    ${OPS_POLICY_VDNS_NAME}    ${OPS_POLICY_VDNS_TYPE}

VCPE Policy Tests
     ${CONFIG_POLICY_VCPE_NAME}=    Create Config VCPE Policy
     Push Config Policy    ${CONFIG_POLICY_VCPE_NAME}    ${CONFIG_POLICY_VCPE_TYPE}
     Get Configs VCPE Policy    
     ${OPS_POLICY_VCPE_NAME}=    Create Ops VCPE Policy
     Push Ops Policy    ${OPS_POLICY_VCPE_NAME}    ${OPS_POLICY_VCPE_TYPE}

VPG Policy Tests
     ${SDNC_POLICY_VPG_NAME}=    Create VPG SDNC Naming Policy
     Push Config Policy    ${SDNC_POLICY_VPG_NAME}    ${CONFIG_POLICY_VFW_TYPE}
     
VOLTE Policy Tests  
     ${OPS_POLICY_VOLTE_NAME}=    Create Ops VOLTE Policy
     Push Ops Policy    ${OPS_POLICY_VOLTE_NAME}    ${OPS_POLICY_VOLTE_TYPE}
     
HPA Policy Tests
     ${OOF_POLICY_HPA_NAME}=    Create OOF HPA Policy
     Push Config Policy    ${OOF_POLICY_HPA_NAME}    ${OOF_POLICY_HPA_TYPE}
     Get OOF HPA Policy

Get Configs VFW Policy
    [Documentation]    Get Config Policy for VFW
    Create Environment    policy    ${CURDIR}
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VFW_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Apply Template    policy    ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create OOF HPA Policy
    [Documentation]    Create OOF Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_HPA
    ${OOF_POLICY_HPA_NAME}=    Set Test Variable    ${policyname1}
    ${hpapolicy}=   Create Dictionary   policy_name=${policyname1}
    ${output} =   Apply Template    policy    ${CREATE_OOF_HPA_TEMPLATE}   ${hpapolicy}
    ${put_resp} =   Run Policy Put Request    ${RESOURCE_PATH_CREATE}   ${output}
    Log    ${put_resp}    
        Should Be Equal As Strings     ${put_resp.status_code}          200
        [Return]    ${policyname1}

Get OOF HPA Policy
    [Documentation]    Get OOF Policy for HPA 
    Create Environment    policy    ${CURDIR}
    ${gethpapolicy}=   Catenate    .*${OOF_POLICY_HPA_NAME}*
    ${hpapolicy_name}=   Create Dictionary    oof_policy_name=${gethpapolicy}
    ${output} =    Apply Template    policy    ${GETOOF_TEMPLATE}    ${hpapolicy_name}
    ${get_resp} =   Run Policy Get Configs Request   ${RESOURCE_PATH_GET_CONFIG}   ${output}
        Should Be Equal As Strings     ${get_resp.status_code}        200
 
Create Config VFW Policy
    [Documentation]    Create Config Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vFirewall
    ${CONFIG_POLICY_VFW_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Apply Template    policy     ${CREATE_CONFIG_VFW_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}

Create VPG SDNC Naming Policy
    [Documentation]    Create VPG SDNC Naming Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =    Create Policy Name
    ${policyname1}=    Catenate    com.${randompolicyname}_ONAP_vPG_Naming
    ${SDNC_POLICY_VPG_NAME}=    Set Test Variable     ${policyname1}
    ${sdncpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =   Apply Template    policy    ${CREATE_SDNC_VPG_TEMPLATE}    ${sdncpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Should Be Equal As Strings  ${put_resp.status_code}    200
    [Return]    ${policyname1}
    
Create VFW SDNC Naming Policy
    [Documentation]    Create VFW SDNC Naming Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =    Create Policy Name
    ${policyname1}=    Catenate    com.${randompolicyname}_ONAP_vFW_Naming
    ${SDNC_POLICY_VFW_NAME}=    Set Test Variable     ${policyname1}
    ${sdncpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =   Apply Template    policy    ${CREATE_SDNC_VFW_TEMPLATE}    ${sdncpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Should Be Equal As Strings  ${put_resp.status_code}    200
    [Return]    ${policyname1}
    
Create Policy Name
     [Documentation]    Generate Policy Name
     [Arguments]    ${prefix}=CSIT_
     ${random}=    Generate Random String    15    [LOWER][NUMBERS]
     ${policyname}=    Catenate    ${prefix}${random}
     [Return]    ${policyname}

Create Ops VFW Policy
	[Documentation]    Create Operational Policy
    Create Environment    policy    ${CURDIR}
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_vFirewall
	${OPS_POLICY_VFW_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Apply Template    policy     ${CREATE_OPS_VFW_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}

Push Ops Policy
    [Documentation]    Push Ops Policy
    [Arguments]    ${policyname}    ${policytype}
    Create Environment    policy    ${CURDIR}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Apply Template    policy    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Config Policy
    [Documentation]    Push Config Policy
    [Arguments]    ${policyname}    ${policytype}
    Create Environment    policy    ${CURDIR}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Apply Template    policy    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Ops Policy
    [Documentation]    Delete Config Policy
    [Arguments]    ${policy_name}
    Create Environment    policy    ${CURDIR}
    ${policyname3}=    Catenate   com.Config_BRMS_Param_${policyname}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
	${output} =     Apply Template    policy    ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Config Policy
    [Documentation]    Delete Ops Policy
    [Arguments]    ${policy_name}
    Create Environment    policy    ${CURDIR}
    ${policyname3}=    Catenate   com.Config_MS_com.${policy_name}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
	${output} =     Apply Template    policy    ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete OOF Policy
    [Documentation]    Delete OOF Policy
    [Arguments]    ${policy_name}
    Create Environment    policy    ${CURDIR}
    ${policyname3}=    Catenate   com.Config_OOF_${policy_name}.1.xml
    ${dict}=    Create Dictionary     policy_name=${policyname3}
    ${output} =    Apply Template    policy    ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =   Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}   ${output}
    Should Be Equal As Strings  ${put_resp.status_code}        200 

Get Configs VDNS Policy
    [Documentation]    Get Config Policy for VDNS
    Create Environment    policy    ${CURDIR}
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VDNS_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Apply Template    policy     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create Config VDNS Policy
    [Documentation]    Create Config Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vLoadBalancer
    ${CONFIG_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Apply Template    policy     ${CREATE_CONFIG_VDNS_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}

Create Ops VDNS Policy
	[Documentation]    Create Operational Policy
    Create Environment    policy    ${CURDIR}
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_vLoadBalancer
	${OPS_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Apply Template    policy     ${CREATE_OPS_VDNS_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Create Config VCPE Policy
    [Documentation]    Create Config Policy
    Create Environment    policy    ${CURDIR}
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vCPE
    ${CONFIG_POLICY_VCPE_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Apply Template    policy     ${CREATE_CONFIG_VCPE_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}
	
Get Configs VCPE Policy
    [Documentation]    Get Config Policy for VCPE
    Create Environment    policy    ${CURDIR}
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VCPE_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Apply Template    policy     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200

Create Ops vCPE Policy
	[Documentation]    Create Operational Policy
    Create Environment    policy    ${CURDIR}
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_vCPE
	${OPS_POLICY_VCPE_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Apply Template    policy     ${CREATE_OPS_VCPE_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Create Ops VolTE Policy
	[Documentation]    Create Operational Policy
    Create Environment    policy    ${CURDIR}
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_VoLTE
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Apply Template    policy     ${CREATE_OPS_VOLTE_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Upload DRL file
    [Documentation]    Upload DRL file1
    ${file_data}=     Get Binary File  ${file_path}
    ${files}=    Create Dictionary    file=${file_data}
   #${CONFIG_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
   # ${files2} = {'file': open('../testsuite/robot/assets/templates/ControlLoopDemo__closedLoopControlName.drl', 'rb')}
   # ${files}=  Create Dictionary  file  ${file_data}
    ${put_resp} =    Run Policy Post form Request    ${RESOURCE_PATH_UPLOAD}    ${files}      
	Should Be Equal As Strings 	${put_resp.status_code} 	200

ListPolicy test
	[Documentation]    Listing Config Policies
	[Arguments]    ${policy_name}
    Create Environment    policy    ${CURDIR}
	${dict}=     Create Dictionary    policy_name=${policy_name}
	${output} =     Apply Template    policy     ${LISTPOLICY_TEMPLATE}    ${dict}
	${put_resp} =        policy_interface.Run Policy Post Request    ${RESOURCE_PATH_LISTPOLICY}    ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Multiple Policy test
    [Documentation]    Push Multiple Policy
    [Arguments]    ${policyname1}	${policyname2}		${policyname3}    ${policytype}
    Create Environment    policy    ${CURDIR}
    ${dict}=     Create Dictionary     policy_name1=${policyname1}  policy_name2=${policyname2}  policy_name3=${policyname3}    policy_type=${policytype}
	${output} =     Apply Template    policy    ${MULTIPLE_PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Multiple Policy test
    [Documentation]    Delete Multiple Policy
    [Arguments]    ${policyname1}	${policyname2}		${policyname3}    ${policytype}
    Create Environment    policy    ${CURDIR}
    ${dict}=     Create Dictionary     policy_name1=${policyname1}  policy_name2=${policyname2}  policy_name3=${policyname3}    policy_type=${policytype}
	${output} =     Apply Template    policy    ${MULTIPLE_UNPUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

