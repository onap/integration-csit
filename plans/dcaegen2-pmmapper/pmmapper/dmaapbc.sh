#!/bin/bash

# $1 is the IP address of the buscontroller
# INITIALIZE: dmaap object
JSON=/tmp/prov.dmaap
cat << EOF > $JSON
{
"version": "1",
"topicNsRoot": "org.onap.dmaap",
"drProvUrl": "https://dmaap-dr-prov:8443",
"dmaapName": "onapCSIT",
"bridgeAdminTopic": "MM_AGENT_PROV"

}
EOF

echo "Initializing /dmaap endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dmaap