#!/bin/bash
echo "Starting teardown script"
kill-instance.sh $DMAAP
kill-instance.sh $KAFKA
kill-instance.sh $ZOOKEEPER
kill-instance.sh datarouter-node
kill-instance.sh datarouter-prov
kill-instance.sh mariadb
kill-instance.sh cbs
kill-instance.sh consul