*** Settings ***
Documentation     Keywords related to checking and updating PRH app config based on CBS config
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           yaml

*** Variables ***
${CONFIGS_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/resources/prh_configs/
${PRH_CONFIG_FILE}    ${CONFIGS_DIR}/prh_config_volume/application_config.yaml
*** Keywords ***

Put key-value to config
    [Arguments]    ${key}    ${value}
    ${prh_config}=    Get PRH config
    set to dictionary    ${prh_config}    ${key}    ${value}
    Set PRH config     ${prh_config}

Get PRH config
    [Arguments]    ${logMessage}=prh config
    ${prh_config_file_content}=    Get File    ${PRH_CONFIG_FILE}
    ${prh_config}=    yaml.Safe Load    ${prh_config_file_content}
    log    ${logMessage}: ${prh_config}
    [Return]    ${prh_config}

Set PRH config
    [Arguments]  ${prh_config}
    ${prh_config_output}=  yaml.Safe Dump  ${prh_config}
    Create File  ${PRH_CONFIG_FILE}  ${prh_config_output}

Set PRH config from file
    [Arguments]     ${config_file_name}
    Copy File    ${config_file_name}    ${PRH_CONFIG_FILE}
    Force PRH config refresh

Set default PRH config
    Set PRH config from file    ${CONFIGS_DIR}/prh-config.yaml

Force PRH config refresh
    ${refresh_response}=    post request    prh_session    /actuator/refresh
    should be equal as integers    ${refresh_response.status_code}    200

Check key-value in PRH app environment
    [Arguments]    ${key}    ${expected_value}
    ${env_response}=    get request    prh_session    /actuator/env/${key}
    should be equal as integers    ${env_response.status_code}    200
    log    ${env_response.content}
    should be equal    ${env_response.json()["property"]["value"]}    ${expected_value}

Set scheduled config updates interval
    [Arguments]    ${cbs_updates_interval}
    Put key-value to config    cbs.updates-interval    ${cbs_updates_interval}
    Force PRH config refresh

Set logging level in config
    [Arguments]    ${logger}   ${level}
    Put key-value to config    logging.level.${logger}    ${level}

Generate random value
    ${some_random_value}     evaluate    random.randint(sys.maxint/10, sys.maxint)    modules=random,sys
    [Return]    ${some_random_value}