#!/bin/sh

chmod -R 775 /opt/app/onap/res
cp -f /opt/app/onap/res/application.properties /opt/app/onap/config
cp -f /opt/app/onap/res/error-messages_en.properties /opt/app/onap/config

echo "importing aai cert."
keytool -import -noprompt -trustcacerts -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -alias aai -import -file /opt/app/onap/res/aai.cert

echo "starting service."
source /startService.sh