#!/bin/bash

# $1 is the IP address of the buscontroller
# INITIALIZE: dmaap object
JSON=/tmp/$$.dmaap
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

# INITIALIZE: dcaeLocation object
JSON=/tmp/$$.loc
cat << EOF > $JSON
{
"dcaeLocationName": "csit-sanfrancisco",
"dcaeLayer": "central-cloud",
"clli": "CSIT12345",
"zone": "zoneA"

}
EOF

echo "Initializing /dcaeLocations endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dcaeLocations
