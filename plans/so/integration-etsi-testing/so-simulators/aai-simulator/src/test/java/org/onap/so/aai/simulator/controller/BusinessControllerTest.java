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
package org.onap.so.aai.simulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import java.io.File;
import java.io.IOException;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.so.aai.simulator.service.providers.CacheServiceProvider;
import org.onap.so.aai.simulator.utils.Constant;
import org.onap.so.aai.simulator.utils.RequestError;
import org.onap.so.aai.simulator.utils.ServiceException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.module.jaxb.JaxbAnnotationModule;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public class BusinessControllerTest {

    private static final String SERVICE_INSTANCES_URL = "/service-instances";

    private static final String SERVICE_NAME = "ServiceTest";

    private static final String SERVICE_INSTANCE_ID = "ccece8fe-13da-456a-baf6-41b3a4a2bc2b";

    private static final String SERVICE_INSTANCE_URL =
            SERVICE_INSTANCES_URL + "/service-instance/" + SERVICE_INSTANCE_ID;

    private static final String SERVICE_TYPE = "vCPE";

    private static final String SERVICE_SUBSCRIPTIONS_URL =
            "/service-subscriptions/service-subscription/" + SERVICE_TYPE;

    private static final String GLOBAL_CUSTOMER_ID = "DemoCustomer";

    private static final String CUSTOMERS_URL = Constant.BUSINESS_URL + "customers/customer/" + GLOBAL_CUSTOMER_ID;

    private static final String PASSWORD = "aai.onap.org:demo123456!";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Value("${spring.security.username}")
    private String username;

    @Autowired
    private CacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putCustomer_successfullyAddedToCache() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));
        final ResponseEntity<Void> actual = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());
        assertTrue(cacheServiceProvider.getCustomer(GLOBAL_CUSTOMER_ID).isPresent());
    }

    @Test
    public void test_getCustomer_ableToRetrieveCustomer() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));
        final String url = getCustomerEndPointUrl();

        invokeHttpPut(url, customer);

        final ResponseEntity<Customer> actual =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), Customer.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Customer actualCustomer = actual.getBody();
        assertEquals(GLOBAL_CUSTOMER_ID, actualCustomer.getGlobalCustomerId());
        assertNotNull(actualCustomer.getResourceVersion());
        assertFalse(actualCustomer.getResourceVersion().isEmpty());
    }

    @Test
    public void test_getCustomer_returnRequestError_ifCustomerNotInCache() throws Exception {
        final String url = getCustomerEndPointUrl();

        final ResponseEntity<RequestError> actual =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(Constant.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(Constant.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    @Test
    public void test_getServiceSubscription_ableToRetrieveServiceSubscriptionFromCache() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));
        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL;

        invokeHttpPut(getCustomerEndPointUrl(), customer);

        final ResponseEntity<ServiceSubscription> actual = restTemplate.exchange(url, HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), ServiceSubscription.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceSubscription actualServiceSubscription = actual.getBody();
        assertEquals(SERVICE_TYPE, actualServiceSubscription.getServiceType());
        assertNotNull(actualServiceSubscription.getRelationshipList());
        assertFalse(actualServiceSubscription.getRelationshipList().getRelationship().isEmpty());
    }

    @Test
    public void test_putSericeInstance_ableToRetrieveServiceInstanceFromCache() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ServiceInstance serviceInstance =
                getObjectFromFile(getFile("test-data/service-instance.json"), ServiceInstance.class);

        invokeHttpPut(url, serviceInstance);

        final Optional<ServiceInstance> actual =
                cacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);

        assertTrue(actual.isPresent());
        final ServiceInstance actualServiceInstance = actual.get();

        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());
        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());

    }

    @Test
    public void test_getSericeInstance_usingServiceInstanceName_ableToRetrieveServiceInstanceFromCache()
            throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ServiceInstance serviceInstance =
                getObjectFromFile(getFile("test-data/service-instance.json"), ServiceInstance.class);

        invokeHttpPut(url, serviceInstance);

        final String serviceInstanceUrl = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCES_URL
                + "?service-instance-name=" + SERVICE_NAME;

        final ResponseEntity<ServiceInstances> actual = restTemplate.exchange(serviceInstanceUrl, HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), ServiceInstances.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstances actualServiceInstances = actual.getBody();
        assertFalse(actualServiceInstances.getServiceInstance().isEmpty());

        assertEquals(SERVICE_NAME, actualServiceInstances.getServiceInstance().get(0).getServiceInstanceName());

    }

    @Test
    public void test_getSericeInstance_usingServiceInstanceId_ableToRetrieveServiceInstanceFromCache()
            throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ServiceInstance serviceInstance =
                getObjectFromFile(getFile("test-data/service-instance.json"), ServiceInstance.class);

        invokeHttpPut(url, serviceInstance);

        final ResponseEntity<ServiceInstance> actual =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), ServiceInstance.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceInstance actualServiceInstance = actual.getBody();

        assertEquals(SERVICE_NAME, actualServiceInstance.getServiceInstanceName());
        assertEquals(SERVICE_INSTANCE_ID, actualServiceInstance.getServiceInstanceId());

    }

    @Test
    public void test_getSericeInstance_usinginvalidServiceInstanceId_shouldReturnError() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ServiceInstance serviceInstance =
                getObjectFromFile(getFile("test-data/service-instance.json"), ServiceInstance.class);

        invokeHttpPut(url, serviceInstance);

        String invalidServiceInstanceUrl = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCES_URL
                + "/service-instance/" + UUID.randomUUID();

        final ResponseEntity<RequestError> actual = restTemplate.exchange(invalidServiceInstanceUrl, HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(Constant.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(Constant.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    @Test
    public void test_getSericeInstance_usinginvalidServiceInstanceName_shouldReturnError() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));

        final String url = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCE_URL;

        final ResponseEntity<Void> response = invokeHttpPut(getCustomerEndPointUrl(), customer);

        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final ServiceInstance serviceInstance =
                getObjectFromFile(getFile("test-data/service-instance.json"), ServiceInstance.class);

        invokeHttpPut(url, serviceInstance);

        final String serviceInstanceUrl = getCustomerEndPointUrl() + SERVICE_SUBSCRIPTIONS_URL + SERVICE_INSTANCES_URL
                + "?service-instance-name=Dummy&depth=2";

        final ResponseEntity<RequestError> actual = restTemplate.exchange(serviceInstanceUrl, HttpMethod.GET,
                new HttpEntity<>(getHttpHeaders()), RequestError.class);

        assertEquals(HttpStatus.NOT_FOUND, actual.getStatusCode());

        final RequestError actualError = actual.getBody();
        final ServiceException serviceException = actualError.getServiceException();

        assertNotNull(serviceException);
        assertEquals(Constant.ERROR_MESSAGE_ID, serviceException.getMessageId());
        assertEquals(Constant.ERROR_MESSAGE, serviceException.getText());
        assertTrue(serviceException.getVariables().contains(HttpMethod.GET.toString()));

    }

    private String getCustomerEndPointUrl() {
        return getBaseUrl() + CUSTOMERS_URL;
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, Void.class);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders());
    }

    private HttpHeaders getHttpHeaders() {
        final HttpHeaders requestHeaders = new HttpHeaders();
        requestHeaders.add("Authorization", getBasicAuth());
        return requestHeaders;
    }

    private File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    private Customer getCustomer(final File file) throws Exception {
        return getObjectFromFile(file, Customer.class);
    }

    private <T> T getObjectFromFile(final File file, final Class<T> clazz) throws Exception {
        final ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JaxbAnnotationModule());

        return mapper.readValue(file, clazz);
    }

    private String getBasicAuth() {
        return "Basic " + new String(Base64.getEncoder().encodeToString((username + ":" + PASSWORD).getBytes()));
    }

    private String getBaseUrl() {
        return "http://localhost:" + port;
    }

}
