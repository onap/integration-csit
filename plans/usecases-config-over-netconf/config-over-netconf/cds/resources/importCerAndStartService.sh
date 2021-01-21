#!/bin/sh

chmod -R 775 /opt/app/onap/res
cp -f /opt/app/onap/res/application.properties /opt/app/onap/config
cp -f /opt/app/onap/res/error-messages_en.properties /opt/app/onap/config

echo "Starting Service..."
source /startService.sh