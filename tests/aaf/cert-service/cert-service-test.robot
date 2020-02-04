*** Settings ***

Documentation     Run healthcheck
Library 	      RequestsLibrary
Resource          ./resources/cert-service-keywords.robot

Suite Setup      Create sessions


*** Test Cases ***

AAF Cert Service Health Check
    [Documentation]   Run healthcheck
    Run Healthcheck