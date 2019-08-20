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
import static org.onap.so.aaisimulator.utils.TestConstants.RELATIONSHIP_URL;
import org.junit.After;
import org.junit.Test;
import org.onap.aai.domain.yang.OwningEntity;
import org.onap.so.aaisimulator.models.Format;
import org.onap.so.aaisimulator.models.Results;
import org.onap.so.aaisimulator.service.providers.OwnEntityCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class OwningEntityControllerTest extends AbstractSpringBootTest {

    private static final String OWN_ENTITY_ID_VALUE = "oe_1";
    private static final String OWN_ENTITY_NAME_VALUE = "oe_2";

    @Autowired
    private OwnEntityCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putOwningEntity_successfullyAddedToCache() throws Exception {
        final String url = getUrl(Constants.OWNING_ENTITY_URL, OWN_ENTITY_ID_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getOwningEntity(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<OwningEntity> actualResponse =
                testRestTemplateService.invokeHttpGet(url, OwningEntity.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final OwningEntity actualOwningEntity = actualResponse.getBody();
        assertEquals(OWN_ENTITY_ID_VALUE, actualOwningEntity.getOwningEntityId());
        assertEquals(OWN_ENTITY_NAME_VALUE, actualOwningEntity.getOwningEntityName());
        assertNotNull(actualOwningEntity.getResourceVersion());

    }

    @Test
    public void test_getOwningEntityCount_correctResult() throws Exception {
        final String url = getUrl(Constants.OWNING_ENTITY_URL, OWN_ENTITY_ID_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getOwningEntity(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Results> actualResponse = testRestTemplateService
                .invokeHttpGet(url + "?resultIndex=0&resultSize=1&format=" + Format.COUNT.getValue(), Results.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Results result = actualResponse.getBody();
        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        assertEquals(1, result.getValues().get(0).get(Constants.OWNING_ENTITY));
    }

    @Test
    public void test_putOwningEntityRelationShip_successfullyAddedToCache() throws Exception {
        final String url = getUrl(Constants.OWNING_ENTITY_URL, OWN_ENTITY_ID_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getOwningEntity(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final String owningEntityRelationshipUrl = url + RELATIONSHIP_URL;

        final ResponseEntity<Void> putResponse = testRestTemplateService.invokeHttpPut(owningEntityRelationshipUrl,
                TestUtils.getOwningEntityRelationship(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, putResponse.getStatusCode());

        final ResponseEntity<OwningEntity> actualResponse =
                testRestTemplateService.invokeHttpGet(url, OwningEntity.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final OwningEntity actualOwningEntity = actualResponse.getBody();
        assertEquals(OWN_ENTITY_ID_VALUE, actualOwningEntity.getOwningEntityId());
        assertEquals(OWN_ENTITY_NAME_VALUE, actualOwningEntity.getOwningEntityName());
        assertNotNull(actualOwningEntity.getRelationshipList());
        assertFalse(actualOwningEntity.getRelationshipList().getRelationship().isEmpty());
        assertNotNull(actualOwningEntity.getRelationshipList().getRelationship().get(0));

    }

}
