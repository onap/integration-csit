#!/usr/bin/env bash

running_containers=$(docker ps --filter name=dfc_ -qa)
running_images=$(docker images -q)

if [ -z "$running_containers" ]
then
    echo "No container requires termination"
else
    echo "Stopping and removing containers"
    docker stop $running_containers
    docker rm $running_containers
    docker rmi $running_images
fi

