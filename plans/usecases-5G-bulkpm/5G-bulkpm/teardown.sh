#!/bin/bash
echo "Starting teardown script"
kill-instance.sh dmaap-message-router
kill-instance.sh dmaap-message-router-kafka
kill-instance.sh dmaap-message-router-zookeeper
kill-instance.sh dmaap-datarouter-node
kill-instance.sh dmaap-datarouter-prov
kill-instance.sh dmaap-dr-prov-mariadb
kill-instance.sh fileconsumer-node
kill-instance.sh dcaegen2-vescollector
kill-instance.sh dcaegen2-datafile-collector
kill-instance.sh dcaegen2-pm-mapper
kill-instance.sh sftp
kill-instance.sh config-binding-service-sim
