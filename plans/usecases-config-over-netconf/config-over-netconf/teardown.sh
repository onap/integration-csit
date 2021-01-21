#!/bin/bash

echo 'Stop, Removing all running containers...'
#docker stop $(docker ps -aq) && docker rm $(docker ps -aq)

echo 'Removing Volumes...'
#echo y | docker volume prune

echo 'Removing Networks...'
#echo y | docker network prune