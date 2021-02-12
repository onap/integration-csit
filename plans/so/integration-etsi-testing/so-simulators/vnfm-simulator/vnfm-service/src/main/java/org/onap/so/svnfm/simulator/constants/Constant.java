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

package org.onap.so.svnfm.simulator.constants;

/**
 * 
 * @author Lathishbabu Ganesan (lathishbabu.ganesan@est.tech)
 * @author ronan.kenny@est.tech
 * @author Eoin Hanan (eoin.hanan@est.tech)
 */
public class Constant {

    public static final String BASE_URL = "/vnflcm/v1";
    public static final String VNF_PROVIDER = "XYZ";
    public static final String VNF_PROVIDER_NAME = "vCPE";
    public static final String VNF_SOFTWARE_VERSION = "1.24";
    public static final String VNFD_VERSION = "onapvcpe01_cxp9025898_4r85d01";
    public static final String VNF_NOT_INSTANTIATED = "NOT_INSTANTIATED";
    public static final String VNF_CONFIG_PROPERTIES =
            "{\"isAutoScaleEnabled\": \"true\",\"isAutoHealingEnabled\": \"true\"}";
    public static final String IN_LINE_RESPONSE_201_CACHE = "inlineResponse201";
    public static final String VNF_PKG_ONBOARDING_NOTIFICATION_CACHE = "vnfPackageOnboardingNotificationCache";
    public static final String PACKAGE_MANAGEMENT_BASE_URL = "/vnfpkgm/v1";
    public static final String SUBSCRIPTION_ENDPOINT = "/subscribe";
    public static final String NOTIFICATION_ENDPOINT = "/notification";
    public static final String NOTIFICATION_CACHE_TEST_ENDPOINT = "/notification-cache-test/{vnfPkgId}";
    public static final String VNFM_ADAPTER_ENDPOINT = "/so/vnfm-adapter/v1/";
    public static final String VNFM_ADAPTER_SUBSCRIPTION_ENDPOINT = VNFM_ADAPTER_ENDPOINT + "vnfpkgm/v1/subscriptions";
}
