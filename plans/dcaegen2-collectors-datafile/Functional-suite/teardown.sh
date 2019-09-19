#!/usr/bin/env bash

running_containers=$(docker ps --filter name=dfc_ -qa)
running_images=$(docker images -q)
docker exec dfc_app0 cat /var/log/ONAP/application.log >> $WORKSPACE/archives/dfc_app0_application.log
docker logs dfc_mr-sim >> $WORKSPACE/archives/dfc_mr-sim.log

if [ -z "$running_containers" ]
then
    echo "No container requires termination"
else
    echo "Stopping and removing containers"
    docker stop $running_containers
    docker rm $running_containers
    docker rmi $running_images
fi

