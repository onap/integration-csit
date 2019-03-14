#!/usr/bin/env bash

docker-compose up -d


DFC=$(docker ps -a -q --filter="name=dfc")

# Wait for initialization of Docker contaienr for DFC
for i in {1..10}; do
if [ $(docker inspect --format '{{ .State.Running }}' $DFC) ]
then
   echo "DFC Container Running"
   break
else
   echo sleep $i
   sleep $i
fi
done

#Wait for initialization of the DFC service
for i in {1..10}; do
if [ $(curl -so /dev/null -w '%{response_code}' http://localhost:8100/heartbeat ) -eq 200 ]
then
   echo "DFC Service running"
   break
else
   echo sleep $i
   sleep $i
fi
done

