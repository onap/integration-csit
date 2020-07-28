*** Settings ***
Documentation     Run healthchecks for DCAE VES
...               Testing /eventListener/v7 and /eventListener/v7/eventBatch endpoints for DCEA VES v7.
...               Testing /eventListener/v5 and /eventListener/v5/eventBatch for DCEA VES v5 with various event feeds from VoLTE, vFW and PNF
Resource          ./resources/dcae_keywords.robot

Test Teardown     Cleanup VES Events
Suite Setup       Run keywords  VES Collector Suite Setup DMaaP  Generate Certs  Create sessions  Create header
Suite Teardown    Run keywords  VES Collector Suite Shutdown DMaaP  Remove Certs