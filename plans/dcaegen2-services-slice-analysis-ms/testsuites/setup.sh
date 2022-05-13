#!/bin/bash

docker login -u docker -p docker nexus3.onap.org:10001

TEST_PLANS_DIR=$WORKSPACE/plans/dcaegen2-services-slice-analysis-ms/testsuites
TEST_SCRIPTS_DIR=$WORKSPACE/scripts/dcaegen2-services-slice-analysis-ms/slice-analysis-ms
TEST_ROBOT_DIR=$WORKSPACE/tests/dcaegen2-services-slice-analysis-ms/testcases
TEST_SCRIPTS_CPS_DIR=$WORKSPACE/scripts/dcaegen2-services-slice-analysis-ms/slice-analysis-ms/cps-aai

docker-compose up -d

ZOOKEEPER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zookeeper)
KAFKA_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kafka)
DMAAP_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' dmaap)
SLICE_ANALYSIS_MS_POSTGRES_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' slice-analysis-ms-postgres)
SLICE_ANALYSIS_MS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sliceanalysisms)
VESCOLLECTOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vescollector)

echo "Waiting for dmaap to come up ..."
for i in {1..10}; do
    dmaap_state=$(curl --write-out '%{http_code}' --silent --output /dev/null $DMAAP_IP:3904/topics)
    if [ $dmaap_state == "200" ]
    then
      break
    else
      sleep 20
    fi
done

#create topics in dmaap
curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "org.onap.dmaap.mr.PERFORMANCE_MEASUREMENTS"}' \
http://$DMAAP_IP:3904/events/unauthenticated.PERFORMANCE_MEASUREMENTS

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "DCAE_CL_RSP"}' \
http://$DMAAP_IP:3904/events/DCAE_CL_RSP

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.ML_RESPONSE_TOPIC"}' \
http://$DMAAP_IP:3904/events/unauthenticated.ML_RESPONSE_TOPIC

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.DCAE_CL_OUTPUT"}' \
http://$DMAAP_IP:3904/events/unauthenticated.DCAE_CL_OUTPUT

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "unauthenticated.VES_NOTIFICATION_OUTPUT"}' \
http://$DMAAP_IP:3904/events/unauthenticated.VES_NOTIFICATION_OUTPUT

curl --header "Content-type: application/json" \
--request POST \
--data '{"topicName": "AAI-EVENT"}' \
http://$DMAAP_IP:3904/events/AAI-EVENT

#build configdb-sim image
cd $TEST_SCRIPTS_DIR
docker build -t configdb_des_sim .

#run configdb-sim
docker run -d --name configdb_des_sim --network=testsuites_slice-analysis-ms-default -p "5000:5000"  configdb_des_sim:latest;
sleep 10
CONFIGDB_DES_SIM_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' configdb_des_sim)
echo "CONFIGDB_DES_SIM_IP=${CONFIGDB_DES_SIM_IP}"

# CPS & AAI set up
cd $TEST_SCRIPTS_CPS_DIR
sh cps-aai-setup.sh
AAI_RESOURCES_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aai-resources )
ROBOT_VARIABLES="-v ZOOKEEPER_IP:${ZOOKEEPER_IP} -v KAFKA_IP:${KAFKA_IP} -v DMAAP_IP:${DMAAP_IP} \
-v SLICE_ANALYSIS_MS_POSTGRES_IP:${SLICE_ANALYSIS_MS_POSTGRES_IP} -v SLICE_ANALYSIS_MS_IP:${SLICE_ANALYSIS_MS_IP} \
-v CONFIGDB_SIM_IP:${CONFIGDB_SIM_IP} -v TEST_ROBOT_DIR:${TEST_ROBOT_DIR} -v VESCOLLECTOR_IP:${VESCOLLECTOR_IP} \
-v AAI_RESOURCES_IP:${AAI_RESOURCES_IP}"
