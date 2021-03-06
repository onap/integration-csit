#!/bin/bash

curl localhost:9200/_cluster/health?pretty=true

echo "BE Health Check:"
curl http://localhost:8080/sdc2/rest/healthCheck

echo ""
echo ""
echo "FE Health Check:"
curl http://localhost:8181/sdc1/rest/healthCheck

echo ""
echo ""
http_code=$(curl -o out.html -w '%{http_code}' -H "Accept: application/json" -H "Content-Type: application/json" -H "USER_ID: jh0003" http://localhost:8080/sdc2/rest/v1/user/demo;)
if [[ ${http_code} != 200 ]]
then
    echo "Error [${http_code}] while checking existence of user"
    return ${http_code}
fi
echo "Check user existence: OK"

