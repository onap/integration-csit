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
import static org.onap.so.aaisimulator.utils.TestConstants.CLOUD_OWNER_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.CLOUD_REGION_NAME;
import static org.onap.so.aaisimulator.utils.TestConstants.RELATIONSHIP_URL;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.so.aaisimulator.models.CloudRegionKey;
import org.onap.so.aaisimulator.service.providers.CloudRegionCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestConstants;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class CloudRegionsControllerTest extends AbstractSpringBootTest {

    private static final CloudRegionKey CLOUD_REGION_KEY = new CloudRegionKey(CLOUD_OWNER_NAME, CLOUD_REGION_NAME);

    @Autowired
    private CloudRegionCacheServiceProvider cloudRegionCacheServiceProvider;

    @After
    public void after() {
        cloudRegionCacheServiceProvider.clearAll();
    }

    @Test
    public void test_putCloudRegion_successfullyAddedToCache() throws Exception {
        final String url = getUrl(Constants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final ResponseEntity<CloudRegion> response = testRestTemplateService.invokeHttpGet(url, CloudRegion.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final CloudRegion cloudRegion = response.getBody();
        assertEquals(CLOUD_OWNER_NAME, cloudRegion.getCloudOwner());
        assertEquals(CLOUD_REGION_NAME, cloudRegion.getCloudRegionId());

        assertNotNull("ResourceVersion should not be null", cloudRegion.getResourceVersion());

    }

    @Test
    public void test_getCloudRegionWithDepthValue_shouldReturnMatchedCloudRegion() throws Exception {
        final String url = getUrl(Constants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final ResponseEntity<CloudRegion> response =
                testRestTemplateService.invokeHttpGet(url + "?depth=2", CloudRegion.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final CloudRegion cloudRegion = response.getBody();
        assertEquals(CLOUD_OWNER_NAME, cloudRegion.getCloudOwner());
        assertEquals(CLOUD_REGION_NAME, cloudRegion.getCloudRegionId());

        assertNotNull("ResourceVersion should not be null", cloudRegion.getResourceVersion());

    }

    @Test
    public void test_putGenericVnfRelationShipToPlatform_successfullyAddedToCache() throws Exception {

        final String url = getUrl(Constants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME);

        invokeCloudRegionHttpPutEndPointAndAssertResponse(url);

        final String relationShipUrl =
                getUrl(Constants.CLOUD_REGIONS, CLOUD_OWNER_NAME, "/" + CLOUD_REGION_NAME, RELATIONSHIP_URL);

        final ResponseEntity<Relationship> responseEntity = testRestTemplateService.invokeHttpPut(relationShipUrl,
                TestUtils.getGenericVnfRelationShip(), Relationship.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());

        final Optional<CloudRegion> optional = cloudRegionCacheServiceProvider.getCloudRegion(CLOUD_REGION_KEY);
        assertTrue(optional.isPresent());

        final CloudRegion actual = optional.get();

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


    private void invokeCloudRegionHttpPutEndPointAndAssertResponse(final String url) throws IOException {
        final ResponseEntity<Void> responseEntity =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getCloudRegion(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, responseEntity.getStatusCode());
    }

}
