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
import static org.onap.so.aaisimulator.utils.Constants.NODES_URL;
import static org.onap.so.aaisimulator.utils.Constants.RESOURCE_LINK;
import static org.onap.so.aaisimulator.utils.Constants.RESOURCE_TYPE;
import static org.onap.so.aaisimulator.utils.Constants.SERVICE_RESOURCE_TYPE;
import static org.onap.so.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.GENERIC_VNFS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.VNF_ID;
import java.io.IOException;
import java.util.Map;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.GenericVnfs;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.so.aaisimulator.models.Format;
import org.onap.so.aaisimulator.models.Results;
import org.onap.so.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.so.aaisimulator.service.providers.NodesCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.onap.so.simulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
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

    @Autowired
    private UserCredentials userCredentials;

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

        invokeCustomerandServiceInstanceUrls();

        final ResponseEntity<ServiceInstance> actual =
                restTemplate.exchange(getUrl(Constants.NODES_URL, SERVICE_INSTANCE_URL), HttpMethod.GET,
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

        invokeCustomerandServiceInstanceUrls();

        final ResponseEntity<Results> actual = restTemplate.exchange(
                getUrl(Constants.NODES_URL, SERVICE_INSTANCE_URL) + "?format=" + Format.PATHED.getValue(),
                HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), Results.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Results result = actual.getBody();

        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        final Map<String, Object> actualMap = result.getValues().get(0);

        assertEquals(CUSTOMERS_URL + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL, actualMap.get(RESOURCE_LINK));
        assertEquals(SERVICE_RESOURCE_TYPE, actualMap.get(RESOURCE_TYPE));

    }

    @Test
    public void test_getNodesGenericVnfs_usingVnfName_ableToRetrieveItFromCache() throws Exception {
        invokeCustomerandServiceInstanceUrls();

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse = invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf());
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

        final String nodeGenericVnfsUrl = getUrl(NODES_URL, GENERIC_VNFS_URL) + "?vnf-name=" + GENERIC_VNF_NAME;
        final ResponseEntity<GenericVnfs> actual = restTemplate.exchange(nodeGenericVnfsUrl, HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), GenericVnfs.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final GenericVnfs genericVnfs = actual.getBody();
        assertEquals(1, genericVnfs.getGenericVnf().size());

        final GenericVnf genericVnf = genericVnfs.getGenericVnf().get(0);
        assertEquals(GENERIC_VNF_NAME, genericVnf.getVnfName());
        assertEquals(VNF_ID, genericVnf.getVnfId());

    }

    private void invokeCustomerandServiceInstanceUrls() throws Exception, IOException {
        final String url = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);

        final ResponseEntity<Void> response = invokeHttpPut(getUrl(CUSTOMERS_URL), TestUtils.getCustomer());

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ResponseEntity<Void> response2 = invokeHttpPut(url, TestUtils.getServiceInstance());
        assertEquals(HttpStatus.ACCEPTED, response2.getStatusCode());
    }

    private String getUrl(final String... urls) {
        return TestUtils.getUrl(port, urls);
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, Void.class);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders());
    }

    private HttpHeaders getHttpHeaders() {
        return TestUtils.getHttpHeaders(userCredentials.getUsers().iterator().next().getUsername());
    }
}
