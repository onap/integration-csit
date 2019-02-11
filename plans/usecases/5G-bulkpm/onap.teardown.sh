#!/bin/bash
echo "Starting teardown script"
DFC_POD=$(kubectl -n onap get pods | grep datafile-collector | awk '{print $1}')
kubectl -n onap exec $DFC_POD -it  cat /opt/log/application.log > /tmp/dfc_docker.log
cat /tmp/dfc_docker.log
sleep 3
kill-instance.sh fileconsumer-node
kill-instance.sh sftp