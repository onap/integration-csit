#!/usr/bin/env bash

#Stop dfc

kill-instance.sh dfc_app

#Stop all simulators 

kill-instance.sh dfc_dr-sim
kill-instance.sh dfc_dr-redir-sim
kill-instance.sh dfc_mr-sim
kill-instance.sh dfc_sftp-server
kill-instance.sh dfc_ftpes-server-vsftpd