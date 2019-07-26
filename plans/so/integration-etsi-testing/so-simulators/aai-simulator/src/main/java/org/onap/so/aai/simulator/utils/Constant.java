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
package org.onap.so.aai.simulator.utils;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class Constant {

    public static final String BASE_URL = "/simulator/aai/v15/";

    public static final String BUSINESS_URL = BASE_URL + "/business/";

    public static final String HEALTHY = "healthy";

    public static final String CUSTOMER_CACHE = "customer-cache";

    public static final String ERROR_MESSAGE_ID = "SVC3001";

    public static final String ERROR_MESSAGE = "Resource not found for %1 using id %2 (msg=%3) (ec=%4)";

    private Constant() {}

}
