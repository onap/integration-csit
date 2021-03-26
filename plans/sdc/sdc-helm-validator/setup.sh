#!/bin/bash

export SDC_HELM_VALIDATOR="sdc-helm-validator"

unset http_proxy
unset https_proxy

docker run -p 8080:8080 -d --name ${SDC_HELM_VALIDATOR} nexus3.onap.org:10001/onap/org.onap.sdc.sdc-helm-validator:latest

# Wait container ready
HELM_VALIDATOR_IP='none'
for i in {1..5}
do
  HELM_VALIDATOR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${SDC_HELM_VALIDATOR})
  RESP_CODE=$(curl -s http://${HELM_VALIDATOR_IP}:8080/actuator/health | python2 -c 'import json,sys;obj=json.load(sys.stdin);print obj["status"]')
   if [[ "$RESP_CODE" == "UP" ]]; then
       echo 'SDC Helm Validator is ready'
       break
   fi

  echo 'Waiting for SDC Helm Validator to start up...'
  sleep 10s
done

echo HELM_VALIDATOR_IP=${HELM_VALIDATOR_IP}

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v VALIDATOR:${HELM_VALIDATOR_IP}:8080"
