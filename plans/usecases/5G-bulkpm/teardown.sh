#!/bin/bash
echo "Starting teardown script"
docker exec dfc /bin/sh -c "cat /opt/log/application.log"
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
