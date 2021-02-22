/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2019 Nordix Foundation.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * ============LICENSE_END=========================================================
 */
package org.onap.so.multicloudsimulator.utils;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class Constants {

    public static final String BASE_URL = "/api/multicloud/v1";

    public static final String OPERATIONS_URL = BASE_URL + "/operations";

    public static final String SERVICE_TOPOLOGY_OPERATION_CACHE = "service-topology-operation-cache";

    public static final String HEALTHY = "healthy";

    public static final String YES = "Y";

    public static final String SERVICE_TOPOLOGY_OPERATION = "service-topology-operation";

    public static final String RESTCONF_CONFIG_END_POINT = "restconf/config/GENERIC-RESOURCE-API:services/service/";

    public static final String VNF_DATA_VNF_TOPOLOGY = "/vnf-data/vnf-topology/";

    public static final String SERVICE_DATA_VNFS_VNF = "/service-data/vnfs/vnf/";

    private Constants() {}
}
