#!/usr/bin/env bash
set +e
docker exec -it dfc_app0 cat /var/log/ONAP/application.log > $WORKSPACE/archives/dfc_app0_application.log
kill-instance.sh dfc_app0
set -e
exit 0
