*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.

*** Variables ***
${GLOBAL_APPLICATION_ID}           robot-dcaegen2
${GLOBAL_DCAE_CONSUL_URL}          http://135.205.228.129:8500
${GLOBAL_DCAE_CONSUL_URL1}         http://135.205.228.170:8500
${GLOBAL_DCAE_VES_URL}             http://localhost:8443/eventlistener/v5
${GLOBAL_DCAE_USERNAME}            console
${GLOBAL_DCAE_PASSWORD}            ZjJkYjllMjljMTI2M2Iz
${VESC_HTTPS_USER}                 sample1
${VESC_HTTPS_PD}                   sample1
${VESC_HTTPS_WRONG_PD}             sample
${VESC_HTTPS_WRONG_USER}           sample
${VESC_ROOTCA_CERT}                %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/rootCA.crt
${VESC_ROOTCA_KEY}                 %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/rootCAdec.key
${VESC_WRONG_CERT}                 %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/wrong.crt
${VESC_WRONG_KEY}                  %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/wrong.key
${VESC_OUTDATED_CERT}              %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/outdated.crt
${VESC_OUTDATED_KEY}               %{WORKSPACE}/tests/dcaegen2/testcases/assets/certs/outdated.key