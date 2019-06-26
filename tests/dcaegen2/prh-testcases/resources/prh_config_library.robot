*** Settings ***
Documentation     Keywords related to checking and updating PRH app config based on CBS config
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections

*** Variables ***
${CONFIGS_DIR}    %{WORKSPACE}/tests/dcaegen2/prh-testcases/resources/prh_configs/

*** Keywords ***

Put key-value to consul
    [Arguments]    ${key}    ${value}
    ${prh_config}=    Get PRH config from consul
    set to dictionary    ${prh_config}    ${key}    ${value}
    Set PRH config in consul  ${prh_config}

Get PRH config from consul
    [Arguments]    ${logMessage}=prh config in consul
    ${phr_config_response}=    get request    consul_session    /v1/kv/dcae-prh?raw
    log    ${logMessage}: ${phr_config_response.content}
    [Return]    ${phr_config_response.json()}

Set PRH config in consul
    [Arguments]  ${prh_config}
    put request    consul_session    /v1/kv/dcae-prh    json=${prh_config}
    Get PRH config from consul    prh config in consul after update

Set PRH CBS config from file
    [Arguments]     ${config_file_name}
    ${config_file_content}=    get file    ${config_file_name}
    ${config_json}=    to json    ${config_file_content}
    Set PRH config in consul    ${config_json}
    Force PRH config refresh

Set default PRH CBS config
    Set PRH CBS config from file    ${CONFIGS_DIR}/prh-config.json

Force PRH config refresh
    ${refresh_response}=    post request    prh_session    /actuator/refresh
    should be equal as integers    ${refresh_response.status_code}    200

Check key-value in PRH app environment
    [Arguments]    ${key}    ${expected_value}
    ${env_response}=    get request    prh_session    /actuator/env/${key}
    should be equal as integers    ${env_response.status_code}    200
    log    ${env_response.content}
    should be equal    ${env_response.json()["property"]["value"]}    ${expected_value}

Set scheduled CBS updates interval
    [Arguments]    ${cbs_updates_interval}
    Put key-value to consul    cbs.updates-interval    ${cbs_updates_interval}
    Force PRH config refresh

Set logging level in CBS
    [Arguments]    ${logger}   ${level}
    Put key-value to consul    logging.level.${logger}    ${level}

Generate random value
    ${some_random_value}     evaluate    random.randint(sys.maxint/10, sys.maxint)    modules=random,sys
    [Return]    ${some_random_value}