#!/bin/bash
# Kill dfc and all simulator

running_containers=$(docker ps --filter name=dfc_ -q)


if [ -z "$running_containers" ]
then
    echo "No container requires termination"
else
    echo "Stopping and removing containers"
    docker stop $running_containers
    docker rm $running_containers
fi

