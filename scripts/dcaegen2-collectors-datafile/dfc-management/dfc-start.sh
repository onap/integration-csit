#!/bin/bash

set -x

#Start DFC app

DOCKER_SIM_NWNAME="dfcnet"
echo "Creating docker network $DOCKER_SIM_NWNAME, if needed"
docker network ls| grep $DOCKER_SIM_NWNAME > /dev/null || docker network create $DOCKER_SIM_NWNAME

docker-compose up -d

DFC_APP="$(docker ps -q --filter='name=dfc_app0')"

#Wait for initialization of docker containers for dfc app and all simulators
for i in {1..10}; do
  if [ $(docker inspect --format '{{ .State.Running }}' $DFC_APP) ]
    then
      echo "DFC app Running"
      # enable TRACE logging of DFC
      docker exec $DFC_APP /bin/sh -c " sed -i 's/org.onap.dcaegen2.collectors.datafile: WARN/org.onap.dcaegen2.collectors.datafile: TRACE/g' /opt/app/datafile/config/application.yaml"

      #enable TRACE logging of spring-framework
      docker exec $DFC_APP /bin/sh -c " sed -i 's/org.springframework.data: ERROR/org.springframework.data: TRACE/g' /opt/app/datafile/config/application.yaml"

      docker restart $DFC_APP
      sleep 10

      break
    else
      echo sleep $i
      sleep $i
  fi
done
