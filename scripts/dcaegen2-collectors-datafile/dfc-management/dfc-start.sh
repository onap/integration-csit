#!/bin/bash

#Start DFC app 

docker-compose up -d 

DFC_APP="$(docker ps -q --filter='name=dfc_app')"

#Wait for initialization of docker containers for dfc app and all simulators
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $DFC_APP) ]
 then
   echo "DFC app Running"
   break
 else
   echo sleep $i
   sleep $i
 fi 
done

