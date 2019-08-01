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
package org.onap.so.aaisimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.onap.so.aaisimulator.utils.Constants.RESOURCE_LINK;
import static org.onap.so.aaisimulator.utils.Constants.RESOURCE_TYPE;
import static org.onap.so.aaisimulator.utils.Constants.SERVICE_RESOURCE_TYPE;
import static org.onap.so.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.so.aaisimulator.utils.TestUtils.getJsonString;
import java.io.IOException;
import java.util.Map;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.so.aaisimulator.models.Format;
import org.onap.so.aaisimulator.models.Result;
import org.onap.so.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.so.aaisimulator.service.providers.NodesCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public class NodesControllerTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Value("${spring.security.username}")
    private String username;

    @Autowired
    private NodesCacheServiceProvider nodesCacheServiceProvider;

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @After
    public void after() {
        nodesCacheServiceProvider.clearAll();
        customerCacheServiceProvider.clearAll();
    }

    @Test
    public void test_getNodesSericeInstance_usingServiceInstanceId_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), getCustomer());

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ResponseEntity<Void> response2 = invokeHttpPut(url, getServiceInstance());
        assertEquals(HttpStatus.ACCEPTED, response2.getStatusCode());

        final ResponseEntity<ServiceInstance> actual =
                restTemplate.exchange(getNodesEndPointUrl() + SERVICE_INSTANCE_URL, HttpMethod.GET,
                        new HttpEntity<>(getHttpHeaders()), ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());

    }

    @Test
    public void test_getNodesSericeInstance_usingServiceInstanceIdAndFormatPathed_ableToRetrieveServiceInstanceFromCache()
            throws Exception {

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), getCustomer());

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ResponseEntity<Void> response2 = invokeHttpPut(url, getServiceInstance());
        assertEquals(HttpStatus.ACCEPTED, response2.getStatusCode());

        final ResponseEntity<Result> actual = restTemplate.exchange(
                getNodesEndPointUrl() + SERVICE_INSTANCE_URL + "?format=" + Format.PATHED.getValue(), HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), Result.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Result result = actual.getBody();

        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        final Map<String, Object> actualMap = result.getValues().get(0);

        assertEquals(CUSTOMERS_URL + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL, actualMap.get(RESOURCE_LINK));
        assertEquals(SERVICE_RESOURCE_TYPE, actualMap.get(RESOURCE_TYPE));

    }

    private String getNodesEndPointUrl() {
        return TestUtils.getBaseUrl(port) + Constants.NODES_URL;
    }


    private String getCustomerEndPointUrl() {
        return TestUtils.getBaseUrl(port) + CUSTOMERS_URL;
    }

    private String getCustomer() throws Exception, IOException {
        return getJsonString("test-data/business-customer.json");
    }

    private String getServiceInstance() throws Exception, IOException {
        return getJsonString("test-data/service-instance.json");
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, Void.class);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders());
    }

    private HttpHeaders getHttpHeaders() {
        return TestUtils.getHttpHeaders(username);
    }
}
