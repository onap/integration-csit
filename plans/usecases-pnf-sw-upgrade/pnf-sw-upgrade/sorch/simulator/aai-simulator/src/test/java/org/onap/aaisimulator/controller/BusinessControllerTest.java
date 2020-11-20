/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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
package org.onap.aaisimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.TestConstants.CUSTOMER_BASE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SVC_INSTANCE_CUSTOMER_ID;
import static org.onap.aaisimulator.utils.TestConstants.SVC_INSTANCE_CUSTOMER_NAME;
import static org.onap.aaisimulator.utils.TestConstants.SVC_INSTANCE_URL;
import static org.onap.aaisimulator.utils.TestConstants.SVC_SUBSCRIPTIONS_URL;
import static org.onap.aaisimulator.utils.TestUtils.getSvcInstance;

import java.io.IOException;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.aaisimulator.utils.Constants;
import org.onap.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class BusinessControllerTest extends AbstractSpringBootTest {

    @Autowired
    private CustomerCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_getSvcInstance_usingServiceInstanceId_fromCache() throws Exception {
        final String url = getUrl(CUSTOMER_BASE_URL, SVC_SUBSCRIPTIONS_URL, SVC_INSTANCE_URL);

        final ResponseEntity<Void> responseEntity = testRestTemplateService
            .invokeHttpPut(url, getSvcInstance(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final ResponseEntity<ServiceInstance> actual = testRestTemplateService
            .invokeHttpGet(url, ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SVC_INSTANCE_CUSTOMER_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SVC_INSTANCE_CUSTOMER_ID, actualServiceInstance.getServiceInstanceId());
    }

    @Test
    public void test_postForServiceInstanceId_fromCache() throws Exception {
        addServiceInstnceToCache();
        final HttpHeaders httpHeaders = testRestTemplateService.getHttpHeaders();
        httpHeaders.add(X_HTTP_METHOD_OVERRIDE, HttpMethod.PATCH.toString());
        httpHeaders.remove(HttpHeaders.CONTENT_TYPE);
        httpHeaders.add(HttpHeaders.CONTENT_TYPE, Constants.APPLICATION_MERGE_PATCH_JSON);

        final String svcInstanceUrl = getUrl(CUSTOMER_BASE_URL, SVC_SUBSCRIPTIONS_URL, SVC_INSTANCE_URL);
        final ResponseEntity<Void> postServiceInstanceResponse = testRestTemplateService
            .invokeHttpPost(httpHeaders, svcInstanceUrl, TestUtils.getSvcInstance(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, postServiceInstanceResponse.getStatusCode());

        final ResponseEntity<ServiceInstance> response =
            testRestTemplateService.invokeHttpGet(svcInstanceUrl, ServiceInstance.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final ServiceInstance actualServiceInstance = response.getBody();

        assertEquals(SVC_INSTANCE_CUSTOMER_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SVC_INSTANCE_CUSTOMER_ID, actualServiceInstance.getServiceInstanceId());

    }

    private void addServiceInstnceToCache() throws Exception, IOException {
        final ResponseEntity<Void> serviceInstanceResponse =
            testRestTemplateService.invokeHttpPut(getUrl(CUSTOMER_BASE_URL, SVC_SUBSCRIPTIONS_URL, SVC_INSTANCE_URL),
                TestUtils.getSvcInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, serviceInstanceResponse.getStatusCode());
    }
}