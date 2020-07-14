#!/bin/bash

docker exec -i dfc_app0 cat /var/log/ONAP/application.log
docker kill dfc_app0
docker rm dfc_app0
