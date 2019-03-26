#!/usr/bin/env bash

DFC_ROOT=$WORKSPACE/scripts/dcaegen2-collectors-datafile/dfc-management
cd $DFC_ROOT
source dfc-start.sh

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

