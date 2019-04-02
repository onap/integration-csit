#!/bin/bash
# $1 is the IP address of the buscontroller

# INITIALIZE: dmaap object
echo $'\nInitializing /dmaap endpoint'
JSON=/tmp/dmaap.json
cat << EOF > $JSON
{
"version": "1",
"topicNsRoot": "topic.org.onap.dmaap",
"drProvUrl": "https://dmaap-dr-prov:8443",
"dmaapName": "mr",
"bridgeAdminTopic": "MM_AGENT_PROV"

}
EOF
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dmaap

# INITIALIZE: dcaeLocation object
echo $'\nInitializing /dcaeLocations endpoint'
JSON=/tmp/dcaeLocation.json
cat << EOF > $JSON
{
"dcaeLocationName": "csit-pmmapper",
"dcaeLayer": "central-cloud",
"clli": "CSIT",
"zone": "zoneA"
}
EOF
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dcaeLocations

# INITIALIZE: MR object in 1 site
echo $'\nInitializing /mr_clusters endpoint'
DMAAP=$(docker ps -a -q --filter="name=dmaap_1")
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
JSON=/tmp/mr.json
cat << EOF > $JSON
{
"dcaeLocationName": "csit-pmmapper",
"fqdn": "${DMAAP_MR_IP}",
"topicProtocol" : "http",
"topicPort": "3904"
}
EOF
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/mr_clusters

# CREATING: MR Topic
echo $'\nInitializing /topic endpoint'
JSON=/tmp/topic.json
cat << EOF > $JSON
{
"topicName":"test1",
"topicDescription":"PM Mapper - VES Event",
"owner":"pmmapper"
}
EOF
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/topics

# CREATING: MR Client
echo $'\nInitializing /mr_clients endpoint'
JSON=/tmp/mrclients.json
cat << EOF > $JSON
{
"fqtn": "topic.org.onap.dmaap.mr.test1",
"dcaeLocationName": "csit-pmmapper",
"clientRole": "org.onap.dmaap.mr.topic",
"action": [ "pub", "view" ]
}
EOF
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/mr_clients
sleep 5