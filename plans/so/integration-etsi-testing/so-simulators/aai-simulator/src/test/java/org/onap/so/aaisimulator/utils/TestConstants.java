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

import org.onap.so.aaisimulator.utils.Constants;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class TestConstants {

    public static final String SERVICE_INSTANCES_URL = "/service-instances";

    public static final String SERVICE_NAME = "ServiceTest";

    public static final String SERVICE_INSTANCE_ID = "ccece8fe-13da-456a-baf6-41b3a4a2bc2b";

    public static final String SERVICE_INSTANCE_URL =
            SERVICE_INSTANCES_URL + "/service-instance/" + SERVICE_INSTANCE_ID;

    public static final String SERVICE_TYPE = "vCPE";

    public static final String SERVICE_SUBSCRIPTIONS_URL =
            "/service-subscriptions/service-subscription/" + SERVICE_TYPE;

    public static final String GLOBAL_CUSTOMER_ID = "DemoCustomer";

    public static final String CUSTOMERS_URL = Constants.CUSTOMER_URL + GLOBAL_CUSTOMER_ID;

    public static final String RELATIONSHIP_URL = "/relationship-list/relationship";

    private TestConstants() {}

}
