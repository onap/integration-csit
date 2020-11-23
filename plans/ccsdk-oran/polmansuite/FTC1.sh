#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2020 Nordix Foundation. All rights reserved.
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


TC_ONELINE_DESCR="Sanity test, create service and then create,update and delete a policy using http/https and Agent REST/DMAAP with/without SDNC controller"

#App names to include in the test, space separated list
INCLUDED_IMAGES="CBS CONSUL CP CR MR PA RICSIM SDNC"

#Supported test env file (profile)
SUPPORTED_PROFILES="ONAP-MASTER ONAP-GUILIN"

. ../common/testcase_common.sh  $@
. ../common/agent_api_functions.sh
. ../common/ricsimulator_api_functions.sh
. ../common/cr_api_functions.sh

#### TEST BEGIN ####


generate_uuid

# Tested variants of REST/DMAAP/SDNC config
TESTED_VARIANTS="REST   DMAAP"
#Test agent and simulator protocol versions (others are http only)
TESTED_PROTOCOLS="HTTP HTTPS"

for __httpx in $TESTED_PROTOCOLS ; do
    for interface in $TESTED_VARIANTS ; do

        echo "#####################################################################"
        echo "#####################################################################"
        echo "### Testing agent: $interface using $__httpx"
        echo "#####################################################################"
        echo "#####################################################################"

        # Clean container and start all needed containers #
        clean_containers

        if [ $__httpx == "HTTPS" ]; then
            use_cr_https
            #echo "Using secure ports between agent and MR"
            use_mr_https
            #"Using secure ports towards simulators"
            use_simulator_https
            use_agent_rest_https
        else
            use_cr_http
            #"Using non-secure ports between agent and MR"
            use_mr_http
            #"Using non-secure ports towards simulators"
            use_simulator_http
            use_agent_rest_http
        fi

        start_ric_simulators ricsim_g1 1  OSC_2.1.0
        start_ric_simulators ricsim_g2 1  STD_1.1.3

        start_mr

        start_cr

        start_policy_agent

        set_agent_debug

        # Create service to be able to receive events when rics becomes available
        # Must use rest towards the agent since dmaap is not configured yet
        api_put_service 201 "ric-registration" 0 "$CR_PATH/ric-registration"

        if [ $interface == "REST+SDNC" ] || [ $interface == "DMAAP+SDNC" ]; then

            start_sdnc

            if [ $__httpx == "HTTPS" ]; then
                # "Using secure ports towards SDNC"
                use_sdnc_https
            else
                #"Using non-secure ports towards SDNC"
                use_sdnc_http
            fi
        fi

        cr_equal received_callbacks 0

        start_consul_cbs

        if [ $interface == "REST+SDNC" ] || [ $interface == "DMAAP+SDNC" ]; then
            prepare_consul_config      SDNC    ".consul_config.json"
        else
            prepare_consul_config      NOSDNC  ".consul_config.json"
        fi

        consul_config_app                      ".consul_config.json"

        start_control_panel

        if [ $interface == "DMAAP" ] || [ $interface == "DMAAP+SDNC" ]; then
            if [ $__httpx == "HTTPS" ]; then
                echo "Using secure ports towards dmaap"
                use_agent_dmaap_https
            else
                echo "Using non-secure ports towards dmaap"
                use_agent_dmaap_http
            fi
        else
            if [ $__httpx == "HTTPS" ]; then
                echo "Using secure ports towards the agent"
                use_agent_rest_https
            else
                echo "Using non-secure ports towards the agent"
                use_agent_rest_http
            fi
        fi

        mr_equal requests_submitted 0

        sim_put_policy_type 201 ricsim_g1_1 1 testdata/OSC/sim_1.json

        if [ "$PMS_VERSION" == "V2" ]; then
            api_equal json:rics 2 60

            api_equal json:policy-types 2 120

            api_equal json:policies 0

            api_equal json:policy-instances 0
        else
            api_equal json:rics 2 60

            api_equal json:policy_schemas 2 120

            api_equal json:policy_types 2

            api_equal json:policies 0

            api_equal json:policy_ids 0
        fi

        echo "############################################"
        echo "############## Health check ################"
        echo "############################################"

        api_get_status 200

        echo "############################################"
        echo "##### Service registry and supervision #####"
        echo "############################################"

        api_put_service 201 "serv1" 1000 "$CR_PATH/1"

        api_get_service_ids 200 "serv1" "ric-registration"

        api_put_services_keepalive 200 "serv1"

        echo "############################################"
        echo "############## RIC Repository ##############"
        echo "############################################"

        api_get_rics 200 NOTYPE "ricsim_g1_1:me1_ricsim_g1_1,me2_ricsim_g1_1:1:AVAILABLE  ricsim_g2_1:me1_ricsim_g2_1,me2_ricsim_g2_1:EMPTYTYPE:AVAILABLE"

        echo "############################################"
        echo "########### A1 Policy Management ###########"
        echo "############################################"

        if [ "$PMS_VERSION" == "V2" ]; then
            notificationurl=$CR_PATH/2
        else
            notificationurl=""
        fi
        api_put_policy 201 "serv1" ricsim_g1_1 1 5000 NOTRANSIENT $notificationurl testdata/OSC/pi1_template.json
        api_put_policy 200 "serv1" ricsim_g1_1 1 5000 NOTRANSIENT $notificationurl testdata/OSC/pi1_template.json

        api_put_policy 201 "serv1" ricsim_g2_1 NOTYPE 5100 NOTRANSIENT $notificationurl testdata/STD/pi1_template.json
        api_put_policy 200 "serv1" ricsim_g2_1 NOTYPE 5100 NOTRANSIENT $notificationurl testdata/STD/pi1_template.json

        api_delete_policy 204 5000

        api_delete_policy 204 5100

        api_equal json:policies 0

        if [ "$PMS_VERSION" == "V2" ]; then
            api_equal json:policy-instances 0
        else
            api_equal json:policy_ids 0
        fi

        if [ "$PMS_VERSION" == "V2" ]; then
            cr_equal received_callbacks?id=ric-registration 2

            cr_api_check_all_sync_events 200 ric-registration ricsim_g1_1 ricsim_g2_1
        fi

        if [ $interface == "DMAAP" ] || [ $interface == "DMAAP+SDNC" ]; then
            VAL=11 # Number of Agent API calls over DMAAP
            mr_equal requests_fetched $VAL
            mr_equal responses_submitted $VAL
            mr_equal responses_fetched $VAL
            mr_equal current_requests 0
            mr_equal current_responses 0
        else
            mr_equal requests_submitted 0
        fi

        if [ $interface == "REST+SDNC" ] || [ $interface == "DMAAP+SDNC" ]; then
            sim_contains_str ricsim_g1_1 remote_hosts "a1-controller"
            sim_contains_str ricsim_g2_1 remote_hosts "a1-controller"
        else
            sim_contains_str ricsim_g1_1 remote_hosts "policy-agent"
            sim_contains_str ricsim_g2_1 remote_hosts "policy-agent"
        fi

        check_policy_agent_logs
        check_control_panel_logs

        store_logs          "${__httpx}__${interface}"

    done

done

#### TEST COMPLETE ####


print_result

auto_clean_containers