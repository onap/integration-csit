#!/bin/bash
echo "Starting teardown script"
docker exec dfc /bin/sh -c "less /var/log/ONAP/application.log" > /tmp/dfc_docker.log
echo "===== DFC LOG ========"
cat /tmp/dfc_docker.log
sleep 3
echo "===== PM MAPPER LOG ========"
cat /tmp/pmmapper_docker.log.robot
sleep 2
kill-instance.sh tmp_dmaap_1
kill-instance.sh tmp_kafka_1
kill-instance.sh tmp_zookeeper_1
kill-instance.sh vescollector
kill-instance.sh datarouter-node
kill-instance.sh datarouter-prov
kill-instance.sh fileconsumer-node
kill-instance.sh mariadb
kill-instance.sh dfc
kill-instance.sh pmmapper
kill-instance.sh sftp
kill-instance.sh cbs-sim
