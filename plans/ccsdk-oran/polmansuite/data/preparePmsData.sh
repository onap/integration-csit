#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2021 Nordix Foundation. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=================================================
#

# The scripts in data/ will generate some dummy data in the running system.
# It will create:
# one policy type in a1-sim-OSC
# one service in policy agent
# one policy in a1-sim-OSC
# one policy in a1-sim-STD

# Run command:
# ./preparePmsData.sh [policy-agent port] [a1-sim-OSC port] [a1-sim-STD port] [http/https]

policy_agent_port=${1:-8081}
a1_sim_OSC_port=${2:-30001}
a1_sim_STD_port=${3:-30003}
httpx=${4:-"http"}
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

echo "using policy_agent port: "$policy_agent_port
echo "using a1-sim-OSC port: "$a1_sim_OSC_port
echo "using a1-sim-STD port: "$a1_sim_STD_port
echo "using protocol: "$httpx
echo -e "\n"

checkRes (){
  if [ "$res" != "$expect" ]; then
      echo "$res is not expected! exit!"
      exit 1;
  fi
}

echo "policy agent status:"
curlString="curl -skw %{http_code} $httpx://localhost:$policy_agent_port/status"
res=$($curlString)
echo "$res"
expect="hunky dory200"
checkRes
echo -e "\n"

echo "ric1 version:"
curlString="curl -skw %{http_code} $httpx://localhost:$a1_sim_OSC_port/counter/interface"
res=$($curlString)
echo "$res"
expect="OSC_2.1.0200"
checkRes
echo -e "\n"

echo "ric2 version:"
curlString="curl -skw %{http_code} $httpx://localhost:$a1_sim_STD_port/counter/interface"
res=$($curlString)
echo "$res"
expect="STD_1.1.3200"
checkRes
echo -e "\n"

echo "create policy type 1 to ric1:"
curlString="curl -X PUT -skw %{http_code} $httpx://localhost:$a1_sim_OSC_port/policytype?id=1 -H Content-Type:application/json --data-binary @${SHELL_FOLDER}/testdata/OSC/policy_type.json"
res=$($curlString)
echo "$res"
expect="Policy type 1 is OK.201"
checkRes
echo -e "\n"


for i in {1..12}; do
	echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} $httpx://localhost:$policy_agent_port/v2/policy-types"
    res=$($curlString)
    echo "$res"
    expect="{\"policy_type_ids\":[\"\",\"1\"]}200"
    if [ "$res" == "$expect" ]; then
        echo -e "\n"
        break;
    else
        sleep $i
    fi
done

echo "create service 1 to policy agent:"
curlString="curl -k -X PUT -sw  %{http_code} -H accept:application/json -H Content-Type:application/json $httpx://localhost:$policy_agent_port/service --data-binary @testdata/service.json"
res=$($curlString)
echo $res
expect="OK201"
checkRes
echo -e "\n"

echo "create policy 2000 to ric1 with type1 and service1 via policy agent:"
curlString="curl -k -X PUT -sw %{http_code} -H accept:application/json -H Content-Type:application/json $httpx://localhost:$policy_agent_port/policy?id=2000&ric=ric1&service=service1&type=1 --data-binary @testdata/policy.json"
res=$($curlString)
echo $res
expect="201"
checkRes
echo -e "\n"

echo "policy numbers from ric1:"
curlString="curl -skw %{http_code} $httpx://localhost:$a1_sim_OSC_port/counter/num_instances"
res=$($curlString)
echo $res
expect="1200"
checkRes
echo -e "\n"

echo "create policy 2100 to ric2 with service1 via policy agent, no type:"
curlString="curl -k -X PUT -sw %{http_code} -H accept:application/json -H Content-Type:application/json $httpx://localhost:$policy_agent_port/policy?id=2100&ric=ric2&service=service1 --data-binary @testdata/policy.json"
res=$($curlString)
echo $res
expect="201"
checkRes
echo -e "\n"

echo "policy numbers from ric2:"
curlString="curl -skw %{http_code} $httpx://localhost:$a1_sim_STD_port/counter/num_instances"
res=$($curlString)
echo $res
expect="1200"
checkRes
echo -e "\n"

echo "policy id 2000 from policy agent:"
curlString="curl -s -o /dev/null -I -w %{http_code} $httpx://localhost:$policy_agent_port/policy?id=2000"
res=$($curlString)
echo $res
expect="200"
checkRes
echo -e "\n"

echo "policy id 2100 from policy agent:"
curlString="curl -s -o /dev/null -I -w %{http_code} $httpx://localhost:$policy_agent_port/policy?id=2100"
res=$($curlString)
echo $res
expect="200"
checkRes
echo -e "\n"
