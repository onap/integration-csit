#!/bin/bash
echo "Starting teardown script"
docker exec pmmapper /bin/sh -c "cat /var/log/ONAP/dcaegen2/services/pm-mapper/pm-mapper_output.log"
kill-instance.sh $DMAAP
kill-instance.sh $KAFKA
kill-instance.sh $ZOOKEEPER
kill-instance.sh datarouter-node
kill-instance.sh datarouter-prov
kill-instance.sh mariadb
kill-instance.sh cbs
kill-instance.sh consul
kill-instance.sh pmmapper