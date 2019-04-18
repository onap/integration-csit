#!/usr/bin/env bash

echo $1
echo $2

cd ./webapps/vid/WEB-INF/conf/
while read a ; do echo ${a//$1*/$1 = $2} ; done < ./features.properties > ./features.properties.t ; mv ./features.properties{.t,}