*** Settings ***
Documentation     Tests and keywords related to updating PRH app config based on CBS config
Library           RequestsLibrary
Library           Collections

*** Keywords ***

Verify PRH configuration forced refresh
    ${some_random_value}     evaluate    random.randint(sys.maxint/10, sys.maxint)    modules=random,sys
    Put key-value to consul    foo_${some_random_value}    bar_${some_random_value}
    Force PRH config refresh
    Check key-value in PRH app environment    foo_${some_random_value}    bar_${some_random_value}

Put key-value to consul
   [Arguments]    ${key}    ${value}
   ${prh_config}=    Get PRH config from consul
   set to dictionary    ${prh_config}    ${key}    ${value}
   put request    consul_session    /v1/kv/dcae-prh    json=${prh_config}
   Get PRH config from consul    prh config in consul after update

Get PRH config from consul
    [Arguments]    ${logMessage}=prh config in consul
    ${phr_config_response}=    get request    consul_session    /v1/kv/dcae-prh?raw
    log    ${logMessage}: ${phr_config_response.content}
    [Return]    ${phr_config_response.json()}

Force PRH config refresh
    ${refresh_response}=    post request    prh_session    /actuator/refresh
    should be equal as integers    ${refresh_response.status_code}    200

Check key-value in PRH app environment
    [Arguments]    ${key}    ${expected_value}
    ${env_response}=    get request    prh_session    /actuator/env/${key}
    should be equal as integers    ${env_response.status_code}    200
    log    ${env_response.content}
    should be equal    ${env_response.json()["property"]["value"]}    ${expected_value}
