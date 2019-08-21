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
package org.onap.so.aaisimulator.utils;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class Constants {

    public static final String BASE_URL = "/aai/v15";

    public static final String NODES_URL = BASE_URL + "/nodes";

    public static final String BUSINESS_URL = BASE_URL + "/business";

    public static final String CLOUD_INFRASTRUCTURE_URL = BASE_URL + "/cloud-infrastructure";

    public static final String CLOUD_REGIONS = CLOUD_INFRASTRUCTURE_URL + "/cloud-regions/cloud-region/";

    public static final String CUSTOMER_URL = BUSINESS_URL + "/customers/customer/";

    public static final String PROJECT_URL = BUSINESS_URL + "/projects/project/";

    public static final String OWNING_ENTITY_URL = BUSINESS_URL + "/owning-entities/owning-entity/";

    public static final String PLATFORMS_URL = BUSINESS_URL + "/platforms/platform/";

    public static final String NETWORK_URL = BASE_URL + "/network";

    public static final String GENERIC_VNFS_URL = NETWORK_URL + "/generic-vnfs/";

    public static final String RELATIONSHIP_LIST_RELATIONSHIP_URL = "/relationship-list/relationship";

    public static final String BI_DIRECTIONAL_RELATIONSHIP_LIST_URL =
            RELATIONSHIP_LIST_RELATIONSHIP_URL + "/bi-directional";

    public static final String LINES_OF_BUSINESS_URL = BUSINESS_URL + "/lines-of-business/line-of-business/";

    public static final String HEALTHY = "healthy";

    public static final String PROJECT = "project";

    public static final String OWNING_ENTITY = "owning-entity";

    public static final String X_HTTP_METHOD_OVERRIDE = "X-HTTP-Method-Override";

    public static final String SERVICE_RESOURCE_TYPE = "service-instance";

    public static final String RESOURCE_LINK = "resource-link";

    public static final String RESOURCE_TYPE = "resource-type";

    public static final String GENERIC_VNF_VNF_NAME = "generic-vnf.vnf-name";

    public static final String GENERIC_VNF_VNF_ID = "generic-vnf.vnf-id";

    public static final String SERVICE_INSTANCE_SERVICE_INSTANCE_ID = "service-instance.service-instance-id";

    public static final String SERVICE_SUBSCRIPTION_SERVICE_TYPE = "service-subscription.service-type";

    public static final String CUSTOMER_GLOBAL_CUSTOMER_ID = "customer.global-customer-id";

    public static final String COMPOSED_OF = "org.onap.relationships.inventory.ComposedOf";

    public static final String GENERIC_VNF = "generic-vnf";

    public static final String PLATFORM = "platform";

    public static final String USES = "org.onap.relationships.inventory.Uses";

    public static final String PLATFORM_PLATFORM_NAME = "platform.platform-name";

    public static final String LINE_OF_BUSINESS_LINE_OF_BUSINESS_NAME = "line-of-business.line-of-business-name";

    public static final String LINE_OF_BUSINESS = "line-of-business";

    public static final String SERVICE_SUBSCRIPTION = "service-subscription";

    public static final String CUSTOMER_TYPE = "Customer";

    public static final String SERVICE_INSTANCE_SERVICE_INSTANCE_NAME = "service-instance.service-instance-name";

    public static final String CLOUD_REGION_OWNER_DEFINED_TYPE = "cloud-region.owner-defined-type";

    public static final String CLOUD_REGION_CLOUD_REGION_ID = "cloud-region.cloud-region-id";

    public static final String CLOUD_REGION_CLOUD_OWNER = "cloud-region.cloud-owner";

    public static final String LOCATED_IN = "org.onap.relationships.inventory.LocatedIn";

    public static final String CLOUD_REGION = "cloud-region";


    private Constants() {}

}
