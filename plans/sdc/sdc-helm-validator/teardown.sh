#!/bin/bash
echo "Starting teardown script"

running_container=$(docker ps --filter name=sdc-helm-validator -qa)

docker stop $running_container
docker rm $running_container
