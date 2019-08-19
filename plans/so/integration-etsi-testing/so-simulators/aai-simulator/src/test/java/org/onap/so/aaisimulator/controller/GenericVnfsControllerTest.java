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
import static org.onap.so.aaisimulator.utils.TestConstants.CUSTOMERS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.GENERIC_VNF_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.GENERIC_VNF_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.GLOBAL_CUSTOMER_ID;
import static org.onap.so.aaisimulator.utils.TestConstants.PLATFORM_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.RELATIONSHIP_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_ID;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_INSTANCE_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_SUBSCRIPTIONS_URL;
import static org.onap.so.aaisimulator.utils.TestConstants.SERVICE_TYPE;
import static org.onap.so.aaisimulator.utils.TestConstants.VNF_ID;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.so.aaisimulator.service.providers.CustomerCacheServiceProvider;
import org.onap.so.aaisimulator.service.providers.GenericVnfCacheServiceProvider;
import org.onap.so.aaisimulator.service.providers.PlatformCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestRestTemplateService;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public class GenericVnfsControllerTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplateService testRestTemplateService;

    @Autowired
    private CustomerCacheServiceProvider customerCacheServiceProvider;

    @Autowired
    private GenericVnfCacheServiceProvider genericVnfCacheServiceProvider;

    @Autowired
    private PlatformCacheServiceProvider platformVnfCacheServiceProvider;

    @After
    public void after() {
        customerCacheServiceProvider.clearAll();
        genericVnfCacheServiceProvider.clearAll();
        platformVnfCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putGenericVnf_successfullyAddedToCache() throws Exception {

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

        final ResponseEntity<GenericVnf> response =
                testRestTemplateService.invokeHttpGet(genericVnfUrl, GenericVnf.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final GenericVnf actualGenericVnf = response.getBody();
        assertEquals(GENERIC_VNF_NAME, actualGenericVnf.getVnfName());
        assertEquals(VNF_ID, actualGenericVnf.getVnfId());

    }

    @Test
    public void test_putGenericVnfRelation_successfullyAddedToCache() throws Exception {

        addCustomerServiceAndGenericVnf();

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getRelationShip(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());


        final Optional<ServiceInstance> optional =
                customerCacheServiceProvider.getServiceInstance(GLOBAL_CUSTOMER_ID, SERVICE_TYPE, SERVICE_INSTANCE_ID);

        assertTrue(optional.isPresent());

        final ServiceInstance actualServiceInstance = optional.get();
        final RelationshipList actualRelationshipList = actualServiceInstance.getRelationshipList();
        assertNotNull(actualRelationshipList);
        assertFalse(actualRelationshipList.getRelationship().isEmpty());
        final Relationship actualRelationShip = actualRelationshipList.getRelationship().get(0);

        assertEquals(Constants.COMPOSED_OF, actualRelationShip.getRelationshipLabel());

        assertFalse(actualRelationShip.getRelatedToProperty().isEmpty());
        assertFalse(actualRelationShip.getRelationshipData().isEmpty());
        final RelatedToProperty actualRelatedToProperty = actualRelationShip.getRelatedToProperty().get(0);
        final RelationshipData actualRelationshipData = actualRelationShip.getRelationshipData().get(0);

        assertEquals(Constants.GENERIC_VNF_VNF_NAME, actualRelatedToProperty.getPropertyKey());
        assertEquals(GENERIC_VNF_NAME, actualRelatedToProperty.getPropertyValue());
        assertEquals(Constants.GENERIC_VNF_VNF_ID, actualRelationshipData.getRelationshipKey());
        assertEquals(VNF_ID, actualRelationshipData.getRelationshipValue());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);
        assertFalse(relationship.getRelatedToProperty().isEmpty());
        assertEquals(3, relationship.getRelationshipData().size());

        final List<RelatedToProperty> relatedToProperty = relationship.getRelatedToProperty();
        final RelatedToProperty firstRelatedToProperty = relatedToProperty.get(0);
        assertEquals(Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_NAME, firstRelatedToProperty.getPropertyKey());
        assertEquals(SERVICE_NAME, firstRelatedToProperty.getPropertyValue());

        final List<RelationshipData> relationshipData = relationship.getRelationshipData();

        final RelationshipData globalRelationshipData =
                getRelationshipData(relationshipData, Constants.CUSTOMER_GLOBAL_CUSTOMER_ID);
        assertNotNull(globalRelationshipData);
        assertEquals(GLOBAL_CUSTOMER_ID, globalRelationshipData.getRelationshipValue());

        final RelationshipData serviceSubscriptionRelationshipData =
                getRelationshipData(relationshipData, Constants.SERVICE_SUBSCRIPTION_SERVICE_TYPE);
        assertNotNull(serviceSubscriptionRelationshipData);
        assertEquals(SERVICE_TYPE, serviceSubscriptionRelationshipData.getRelationshipValue());

        final RelationshipData serviceInstanceRelationshipData =
                getRelationshipData(relationshipData, Constants.SERVICE_INSTANCE_SERVICE_INSTANCE_ID);
        assertNotNull(serviceInstanceRelationshipData);
        assertEquals(SERVICE_INSTANCE_ID, serviceInstanceRelationshipData.getRelationshipValue());

    }

    @Test
    public void test_putGenericVnfRelationToPlatform_successfullyAddedToCache() throws Exception {
        addCustomerServiceAndGenericVnf();

        final String platformUrl = getUrl(Constants.PLATFORMS_URL, PLATFORM_NAME);
        final ResponseEntity<Void> platformResponse =
                testRestTemplateService.invokeHttpPut(platformUrl, TestUtils.getPlatform(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, platformResponse.getStatusCode());

        final String genericVnfRelationShipUrl = getUrl(GENERIC_VNF_URL, VNF_ID, RELATIONSHIP_URL);
        final ResponseEntity<Void> genericVnfRelationShipResponse = testRestTemplateService
                .invokeHttpPut(genericVnfRelationShipUrl, TestUtils.getPlatformRelatedLink(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, genericVnfRelationShipResponse.getStatusCode());

        final Optional<GenericVnf> genericVnfOptional = genericVnfCacheServiceProvider.getGenericVnf(VNF_ID);
        assertTrue(genericVnfOptional.isPresent());
        final GenericVnf actualGenericVnf = genericVnfOptional.get();
        final RelationshipList relationshipList = actualGenericVnf.getRelationshipList();
        assertNotNull(relationshipList);
        assertFalse(relationshipList.getRelationship().isEmpty());

        final Relationship relationship = relationshipList.getRelationship().get(0);

        assertEquals(Constants.USES, relationship.getRelationshipLabel());
        assertFalse(relationship.getRelationshipData().isEmpty());
        assertEquals(1, relationship.getRelationshipData().size());

        final List<RelationshipData> relationshipData = relationship.getRelationshipData();

        final RelationshipData platformRelationshipData =
                getRelationshipData(relationshipData, Constants.PLATFORM_PLATFORM_NAME);
        assertNotNull(platformRelationshipData);
        assertEquals(PLATFORM_NAME, platformRelationshipData.getRelationshipValue());

    }

    private void addCustomerServiceAndGenericVnf() throws Exception, IOException {
        final ResponseEntity<Void> customerResponse =
                testRestTemplateService.invokeHttpPut(getUrl(CUSTOMERS_URL), TestUtils.getCustomer(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, customerResponse.getStatusCode());

        final String serviceInstanceUrl = getUrl(CUSTOMERS_URL, SERVICE_SUBSCRIPTIONS_URL, SERVICE_INSTANCE_URL);
        final ResponseEntity<Void> serviceInstanceResponse =
                testRestTemplateService.invokeHttpPut(serviceInstanceUrl, TestUtils.getServiceInstance(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, serviceInstanceResponse.getStatusCode());

        final String genericVnfUrl = getUrl(GENERIC_VNF_URL, VNF_ID);
        final ResponseEntity<Void> genericVnfResponse =
                testRestTemplateService.invokeHttpPut(genericVnfUrl, TestUtils.getGenericVnf(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, genericVnfResponse.getStatusCode());

    }

    private RelationshipData getRelationshipData(final List<RelationshipData> relationshipData, final String key) {
        return relationshipData.stream().filter(data -> data.getRelationshipKey().equals(key)).findFirst().orElse(null);
    }


    private String getUrl(final String... urls) {
        return TestUtils.getUrl(port, urls);
    }

}
