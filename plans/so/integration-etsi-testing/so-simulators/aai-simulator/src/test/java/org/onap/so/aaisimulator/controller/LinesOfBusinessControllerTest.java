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
import static org.onap.so.aaisimulator.utils.TestConstants.LINE_OF_BUSINESS_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.RELATIONSHIP_URL;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.LineOfBusiness;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.so.aaisimulator.service.providers.LinesOfBusinessCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestConstants;
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
public class LinesOfBusinessControllerTest {
    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplateService testRestTemplateService;

    @Autowired
    private LinesOfBusinessCacheServiceProvider linesOfBusinessCacheServiceProvider;

    @After
    public void after() {
        linesOfBusinessCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putLineOfBusiness_successfullyAddedToCache() throws Exception {

        final String url = getUrl(Constants.LINES_OF_BUSINESS_URL, LINE_OF_BUSINESS_NAME);
        final ResponseEntity<Void> lineOfBusinessResponse =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getLineOfBusiness(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, lineOfBusinessResponse.getStatusCode());

        final ResponseEntity<LineOfBusiness> response =
                testRestTemplateService.invokeHttpGet(url, LineOfBusiness.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final LineOfBusiness actualLineOfBusiness = response.getBody();
        assertEquals(LINE_OF_BUSINESS_NAME, actualLineOfBusiness.getLineOfBusinessName());
        assertNotNull("resource version should not be null", actualLineOfBusiness.getResourceVersion());

    }

    @Test
    public void test_putGenericVnfRelationShipToPlatform_successfullyAddedToCache() throws Exception {

        final String url = getUrl(Constants.LINES_OF_BUSINESS_URL, LINE_OF_BUSINESS_NAME);
        final ResponseEntity<Void> response =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getLineOfBusiness(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, response.getStatusCode());

        final String relationShipUrl = getUrl(Constants.LINES_OF_BUSINESS_URL, LINE_OF_BUSINESS_NAME, RELATIONSHIP_URL);

        final ResponseEntity<Relationship> responseEntity = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getGenericVnfRelationShip(), Relationship.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final Optional<LineOfBusiness> optional =
                linesOfBusinessCacheServiceProvider.getLineOfBusiness(LINE_OF_BUSINESS_NAME);
        assertTrue(optional.isPresent());

        final LineOfBusiness actual = optional.get();

        assertNotNull(actual.getRelationshipList());
        final List<Relationship> relationshipList = actual.getRelationshipList().getRelationship();
        assertFalse("Relationship list should not be empty", relationshipList.isEmpty());
        final Relationship relationship = relationshipList.get(0);

        assertFalse("RelationshipData list should not be empty", relationship.getRelationshipData().isEmpty());
        assertFalse("RelatedToProperty list should not be empty", relationship.getRelatedToProperty().isEmpty());

        final RelationshipData relationshipData = relationship.getRelationshipData().get(0);
        assertEquals(Constants.GENERIC_VNF_VNF_ID, relationshipData.getRelationshipKey());
        assertEquals(TestConstants.VNF_ID, relationshipData.getRelationshipValue());

        final RelatedToProperty relatedToProperty = relationship.getRelatedToProperty().get(0);
        assertEquals(Constants.GENERIC_VNF_VNF_NAME, relatedToProperty.getPropertyKey());
        assertEquals(TestConstants.GENERIC_VNF_NAME, relatedToProperty.getPropertyValue());

    }

    private String getUrl(final String... urls) {
        return TestUtils.getUrl(port, urls);
    }
}
