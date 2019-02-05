#!/bin/bash
echo "Starting teardown script"
docker exec dfc /bin/sh -c "less /opt/log/application.log" > /tmp/dfc_docker.log
cat /tmp/dfc_docker.log
sleep 3
kill-instance.sh $DMAAP
kill-instance.sh $KAFKA
kill-instance.sh $ZOOKEEPER
kill-instance.sh vescollector
kill-instance.sh datarouter-node
kill-instance.sh datarouter-prov
kill-instance.sh fileconsumer-node
kill-instance.sh mariadb
kill-instance.sh dfc
kill-instance.sh sftp
rm /tmp/addSubscriber.json
rm /tmp/datafile_endpoints.json
rm /tmp/dfc_docker.log