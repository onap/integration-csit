#!/bin/bash

docker exec -it dfc_app0 cat /var/log/ONAP/application.log
docker kill dfc_app0