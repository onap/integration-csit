#!/usr/bin/env bash

set +e
#Stop dfc

docker exec -t dfc_app0 cat /var/log/ONAP/application.log > $WORKSPACE/archives/dfc_app0_application.log
kill-instance.sh dfc_app0

#Stop all simulators 
kill-instance.sh dfc_cbs
kill-instance.sh dfc_consul
kill-instance.sh dfc_dr-sim
kill-instance.sh dfc_dr-redir-sim
kill-instance.sh dfc_mr-sim
kill-instance.sh dfc_sftp-server0
kill-instance.sh dfc_sftp-server1
kill-instance.sh dfc_sftp-server2
kill-instance.sh dfc_sftp-server3
kill-instance.sh dfc_sftp-server4
kill-instance.sh dfc_sftp-server5
kill-instance.sh dfc_ftpes-server-vsftpd0
kill-instance.sh dfc_ftpes-server-vsftpd1
kill-instance.sh dfc_ftpes-server-vsftpd2
kill-instance.sh dfc_ftpes-server-vsftpd3
kill-instance.sh dfc_ftpes-server-vsftpd4
kill-instance.sh dfc_ftpes-server-vsftpd5

set -e


