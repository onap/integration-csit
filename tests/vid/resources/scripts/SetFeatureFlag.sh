#!/usr/bin/env bash

docker cp ./ChangingFeatureFlag.sh vid-server:/usr/local/tomcat/ChangingFeatureFlag.sh
docker exec vid-server /usr/local/tomcat/ChangingFeatureFlag.sh $1 $2
docker exec vid-server rm /usr/local/tomcat/ChangingFeatureFlag.sh