*** Settings ***
Documentation     Tests related to updating PRH app config based on CBS config
Suite Setup       Create sessions
Suite Teardown    Set default PRH CBS config
Resource          resources/prh_sessions.robot
Resource          resources/prh_config_library.robot
Resource          resources/prh_library.robot
Test Timeout      15 seconds

*** Test Cases ***
CBS configuration forced refresh
    [Documentation]    It should be possible to force refresh PRH configuration from CBS
    [Tags]    PRH    coniguration
    ${some_random_value}=     Generate random value
    Put key-value to consul    foo_${some_random_value}    bar_${some_random_value}
    Force PRH config refresh
    Check key-value in PRH app environment    foo_${some_random_value}    bar_${some_random_value}

CBS configuration scheduled refresh
    [Documentation]    PRH should pull for CBS configuration updates according to schedule
    [Tags]    PRH    coniguration
    Set scheduled CBS updates interval   1s
    ${some_random_value}=     Generate random value
    Put key-value to consul    spam_${some_random_value}    ham_${some_random_value}
    wait until keyword succeeds    20x   500ms
    ...    Check key-value in PRH app environment    spam_${some_random_value}    ham_${some_random_value}
    [Teardown]    Set scheduled CBS updates interval    0

PRH log level change based on CBS config
    [Documentation]    It should be possible to change logging levels in PRH based on entries in CBS
    [Tags]    PRH    coniguration    logging
    Set logging level in CBS    org.onap.dcaegen2.services.prh.foo    WARN
    Force PRH config refresh
    Verify logging level    org.onap.dcaegen2.services.prh.foo    WARN