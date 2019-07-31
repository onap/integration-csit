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
import static org.onap.so.aai.simulator.utils.TestConstants.RELATIONSHIP_URL;
import static org.onap.so.aai.simulator.utils.TestUtils.getFile;
import static org.onap.so.aai.simulator.utils.TestUtils.getHttpHeaders;
import static org.onap.so.aai.simulator.utils.TestUtils.getJsonString;
import java.io.IOException;
import java.nio.file.Files;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.OwningEntity;
import org.onap.so.aai.simulator.models.Format;
import org.onap.so.aai.simulator.models.Result;
import org.onap.so.aai.simulator.service.providers.OwnEntityCacheServiceProvider;
import org.onap.so.aai.simulator.utils.Constants;
import org.onap.so.aai.simulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpEntity;
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
public class OwningEntityControllerTest {
    private static final String OWNING_ENTITY_JSON_FILE = "test-data/owning-entity.json";

    private static final String OWN_ENTITY_ID_VALUE = "oe_1";
    private static final String OWN_ENTITY_NAME_VALUE = "oe_2";

    private static final String OWNING_ENTITY_RELATION_SHIP_JSON_FILE = "test-data/owning-entity-relation-ship.json";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Value("${spring.security.username}")
    private String username;

    @Autowired
    private OwnEntityCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putOwningEntity_successfullyAddedToCache() throws Exception {
        final String url = getOwningEntityEndPointUrl() + "/" + OWN_ENTITY_ID_VALUE;
        final String body = new String(Files.readAllBytes(getFile(OWNING_ENTITY_JSON_FILE).toPath()));
        final ResponseEntity<Void> actual = invokeHttpPut(url, body);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<OwningEntity> actualResponse = invokeHttpGet(url, OwningEntity.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final OwningEntity actualOwningEntity = actualResponse.getBody();
        assertEquals(OWN_ENTITY_ID_VALUE, actualOwningEntity.getOwningEntityId());
        assertEquals(OWN_ENTITY_NAME_VALUE, actualOwningEntity.getOwningEntityName());
        assertNotNull(actualOwningEntity.getResourceVersion());

    }

    @Test
    public void test_getOwningEntityCount_correctResult() throws Exception {
        final String url = getOwningEntityEndPointUrl() + "/" + OWN_ENTITY_ID_VALUE;
        final String body = new String(Files.readAllBytes(getFile(OWNING_ENTITY_JSON_FILE).toPath()));
        final ResponseEntity<Void> actual = invokeHttpPut(url, body);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Result> actualResponse =
                invokeHttpGet(url + "?resultIndex=0&resultSize=1&format=" + Format.COUNT.getValue(), Result.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Result result = actualResponse.getBody();
        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        assertEquals(1, result.getValues().get(0).get(Constants.OWNING_ENTITY));
    }

    @Test
    public void test_putOwningEntityRelationShip_successfullyAddedToCache() throws Exception {
        final String url = getOwningEntityEndPointUrl() + "/" + OWN_ENTITY_ID_VALUE;
        final ResponseEntity<Void> actual = invokeHttpPut(url, getJsonString(OWNING_ENTITY_JSON_FILE));
        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final String owningEntityRelationshipUrl = url + RELATIONSHIP_URL;

        final ResponseEntity<Void> putResponse = invokeHttpPut(owningEntityRelationshipUrl, getRelationship());

        assertEquals(HttpStatus.ACCEPTED, putResponse.getStatusCode());

        final ResponseEntity<OwningEntity> actualResponse = invokeHttpGet(url, OwningEntity.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final OwningEntity actualOwningEntity = actualResponse.getBody();
        assertEquals(OWN_ENTITY_ID_VALUE, actualOwningEntity.getOwningEntityId());
        assertEquals(OWN_ENTITY_NAME_VALUE, actualOwningEntity.getOwningEntityName());
        assertNotNull(actualOwningEntity.getRelationshipList());
        assertFalse(actualOwningEntity.getRelationshipList().getRelationship().isEmpty());
        assertNotNull(actualOwningEntity.getRelationshipList().getRelationship().get(0));

    }

    private String getRelationship() throws IOException {
        return TestUtils.getJsonString(OWNING_ENTITY_RELATION_SHIP_JSON_FILE);
    }

    private <T> ResponseEntity<T> invokeHttpGet(final String url, final Class<T> clazz) {
        return restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders(username)), clazz);
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, Void.class);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders(username));
    }

    private String getOwningEntityEndPointUrl() {
        return TestUtils.getBaseUrl(port) + Constants.OWNING_ENTITY_URL;
    }

}
