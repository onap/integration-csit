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
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.so.aai.simulator.service.providers.CustomerServiceProvider;
import org.onap.so.aai.simulator.utils.Constant;
import org.onap.so.aai.simulator.utils.RequestError;
import org.onap.so.aai.simulator.utils.ServiceException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpEntity;
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

    private static final String SERVICE_TYPE = "vCPE";

    private static final String GLOBAL_CUSTOMER_ID = "DemoCustomer";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private CustomerServiceProvider customerServiceProvider;

    @After
    public void after() {
        customerServiceProvider.clearAll();
    }

    @Test
    public void test_putCustomer_successfullyAddedToCache() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));
        final String url = getBaseUrl() + "/customers/customer/" + GLOBAL_CUSTOMER_ID;
        final ResponseEntity<Void> actual = invokeHttpPut(url, customer);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());
        assertTrue(customerServiceProvider.getCustomer(GLOBAL_CUSTOMER_ID).isPresent());
    }

    @Test
    public void test_getCustomer_ableToRetrieveCustomer() throws Exception {
        final Customer customer = getCustomer(getFile("test-data/business-customer.json"));
        final String url = getBaseUrl() + "/customers/customer/" + GLOBAL_CUSTOMER_ID;

        invokeHttpPut(url, customer);

        final ResponseEntity<Customer> actual = restTemplate.getForEntity(url, Customer.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final Customer actualCustomer = actual.getBody();
        assertEquals(GLOBAL_CUSTOMER_ID, actualCustomer.getGlobalCustomerId());
        assertNotNull(actualCustomer.getResourceVersion());
        assertFalse(actualCustomer.getResourceVersion().isEmpty());
    }

    @Test
    public void test_getCustomer_returnRequestError_ifCustomerNotInCache() throws Exception {
        final String url = getBaseUrl() + "/customers/customer/" + GLOBAL_CUSTOMER_ID;

        final ResponseEntity<RequestError> actual = restTemplate.getForEntity(url, RequestError.class);

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
        final String customerUrl = getBaseUrl() + "/customers/customer/" + GLOBAL_CUSTOMER_ID;
        final String url = customerUrl + "/service-subscriptions/service-subscription/" + SERVICE_TYPE;

        invokeHttpPut(customerUrl, customer);

        final ResponseEntity<ServiceSubscription> actual = restTemplate.getForEntity(url, ServiceSubscription.class);

        assertEquals(HttpStatus.OK, actual.getStatusCode());
        assertTrue(actual.hasBody());

        final ServiceSubscription actualServiceSubscription = actual.getBody();
        assertEquals(SERVICE_TYPE, actualServiceSubscription.getServiceType());
        assertNotNull(actualServiceSubscription.getRelationshipList());
        assertFalse(actualServiceSubscription.getRelationshipList().getRelationship().isEmpty());
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        return restTemplate.exchange(url, HttpMethod.PUT, new HttpEntity<>(obj), Void.class);
    }

    private File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    private Customer getCustomer(final File file) throws Exception {
        final ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JaxbAnnotationModule());

        return mapper.readValue(file, Customer.class);
    }

    private String getBaseUrl() {
        return "http://localhost:" + port + Constant.BUSINESS_URL;
    }

}
