#!/bin/bash

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-son-handler/testsuites
TEST_SCRIPTS_DIR=$WORKSPACE/scripts/dcaegen2-services-son-handler/sonhandler
TEST_ROBOT_DIR=$WORKSPACE/tests/dcaegen2-services-son-handler/testcases

docker-compose up -d

ZOOKEEPER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zookeeper)
KAFKA_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kafka)
DMAAP_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dmaap)
SONHMS_POSTGRES_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonhms-postgres)
SONHMS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sonhms.onap)

echo "Waiting for dmaap to come up ..."
for i in {1..10}; do
    dmaap_state=$(curl --write-out '%{http_code}' --silent --output /dev/null $DMAAP_IP:3904/topics)
    if [ $dmaap_state == "200" ]
    then
      break
    else
      sleep 60
    fi
done

#create topics
curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "DCAE_CL_RSP"}' \
http://$DMAAP_IP:3904/events/DCAE_CL_RSP

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.SEC_FAULT_OUTPUT"}' \
http://$DMAAP_IP:3904/events/unauthenticated.SEC_FAULT_OUTPUT

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.VES_MEASUREMENT_OUTPUT"}' \
http://$DMAAP_IP:3904/events/unauthenticated.VES_MEASUREMENT_OUTPUT

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.DCAE_CL_OUTPUT"}' \
http://$DMAAP_IP:3904/events/unauthenticated.DCAE_CL_OUTPUT
echo "topics created"

#build configdb-oof-sim image
cd $TEST_SCRIPTS_DIR
docker build -t configdb_oof_sim .

#run configdb-oof-sim
docker run -d --name configdb_oof_sim --network=testsuites_sonhms-default -p "5000:5000"  configdb_oof_sim:latest;
sleep 60
CONFIGDB_OOF_SIM_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' configdb_oof_sim)
echo "CONFIGDB_OOF_SIM_IP=${CONFIGDB_OOF_SIM_IP}"


ROBOT_VARIABLES="-v ZOOKEEPER_IP:${ZOOKEEPER_IP} -v KAFKA_IP:${KAFKA_IP} -v DMAAP_IP:${DMAAP_IP} -v SONHMS_POSTGRES_IP:${SONHMS_POSTGRES_IP} -v SONHMS_IP:${SONHMS_IP} -v CONFIGDB_OOF_SIM_IP:${CONFIGDB_OOF_SIM_IP} -v TEST_ROBOT_DIR:${TEST_ROBOT_DIR}"
