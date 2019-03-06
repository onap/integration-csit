#!/bin/bash
# $1 is the IP address of the buscontroller
# INITIALIZE: dmaap object
JSON=/tmp/dmaap.json
cat << EOF > $JSON
{
"version": "1",
"topicNsRoot": "org.onap.dmaap",
"drProvUrl": "https://dmaap-dr-prov:8443",
"dmaapName": "DataRouter",
"bridgeAdminTopic": "MM_AGENT_PROV"

}
EOF

echo "Initializing /dmaap endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dmaap

# INITIALIZE: dcaeLocation object
JSON=/tmp/dcaeLocation.json
cat << EOF > $JSON
{
"dcaeLocationName": "csit-pmmapper",
"dcaeLayer": "central-cloud",
"clli": "CSIT",
"zone": "zoneA"
}
EOF

echo "Initializing /dcaeLocations endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/dcaeLocations

# INITIALIZE: MR object in 1 site
DMAAP_MR_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DMAAP)
JSON=/tmp/mr.json
cat << EOF > $JSON
{
"dcaeLocationName": "csit-pmmapper",
"fqdn": "$DMAAP_MR_IP",
"topicProtocol" : "http",
"topicPort": "3904"
}
EOF

echo "Initializing /mr_clusters endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/mr_clusters

# CREATING: DR feed
JSON=/tmp/feed.json
cat << EOF > $JSON
{
"feedName":"pmmapper",
"feedVersion": "1",
"feedDescription":"PM Mapper Feed",
"owner":"bulkpm",
"asprClassification": "unclassified",
"pubs": [
        {
            "dcaeLocationName": "csit-pmmapper",
            "feedId": "1",
            "lastMod": "2015-01-01T15:00:00.000Z",
            "pubId": "10",
            "status": "EMPTY",
            "username": "pmmapper",
            "userpwd": "pmmapper"
        }
        ]
}
EOF
echo "Initializing /feeds endpoint"
curl -v -X POST -d @${JSON} -H "Content-Type: application/json" http://$1:8080/webapi/feeds
sleep 5