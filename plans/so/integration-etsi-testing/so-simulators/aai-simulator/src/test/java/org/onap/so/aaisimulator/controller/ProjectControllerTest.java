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
import static org.onap.so.aaisimulator.utils.TestUtils.getFile;
import static org.onap.so.aaisimulator.utils.TestUtils.getHttpHeaders;
import static org.onap.so.aaisimulator.utils.TestUtils.getJsonString;
import java.io.IOException;
import java.nio.file.Files;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.Project;
import org.onap.so.aaisimulator.models.Result;
import org.onap.so.aaisimulator.service.providers.ProjectCacheServiceProvider;
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
public class ProjectControllerTest {

    private static final String RELATIONSHIP_URL = "/relationship-list/relationship";

    private static final String BUSINESS_PROJECT_JSON_FILE = "test-data/business-project.json";

    private static final String PROJECT_RELATION_SHIP_JSON_FILE = "test-data/business-project-relation-ship.json";

    private static final String PROJECT_NAME_VALUE = "PROJECT_NAME_VALUE";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserCredentials userCredentials;

    @Autowired
    private ProjectCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putProject_successfullyAddedToCache() throws Exception {
        final String url = getProjectEndPointUrl() + "/" + PROJECT_NAME_VALUE;
        final String body = new String(Files.readAllBytes(getFile(BUSINESS_PROJECT_JSON_FILE).toPath()));
        final ResponseEntity<Void> actual = invokeHttpPut(url, body);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Project> actualResponse = invokeHttpGet(url, Project.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Project actualProject = actualResponse.getBody();
        assertEquals(PROJECT_NAME_VALUE, actualProject.getProjectName());
        assertNotNull(actualProject.getResourceVersion());

    }

    @Test
    public void test_putProjectRelationShip_successfullyAddedToCache() throws Exception {
        final String url = getProjectEndPointUrl() + "/" + PROJECT_NAME_VALUE;
        final ResponseEntity<Void> actual = invokeHttpPut(url, getJsonString(BUSINESS_PROJECT_JSON_FILE));
        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final String projectRelationshipUrl = url + RELATIONSHIP_URL;

        final ResponseEntity<Void> putResponse = invokeHttpPut(projectRelationshipUrl, getRelationship());

        assertEquals(HttpStatus.ACCEPTED, putResponse.getStatusCode());

        final ResponseEntity<Project> actualResponse = invokeHttpGet(url, Project.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Project actualProject = actualResponse.getBody();
        assertEquals(PROJECT_NAME_VALUE, actualProject.getProjectName());
        assertNotNull(actualProject.getRelationshipList());
        assertFalse(actualProject.getRelationshipList().getRelationship().isEmpty());
        assertNotNull(actualProject.getRelationshipList().getRelationship().get(0));

    }

    @Test
    public void test_getProjectCount_correctResult() throws Exception {
        final String url = getProjectEndPointUrl() + "/" + PROJECT_NAME_VALUE;
        final String body = new String(Files.readAllBytes(getFile(BUSINESS_PROJECT_JSON_FILE).toPath()));
        final ResponseEntity<Void> actual = invokeHttpPut(url, body);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Result> actualResponse =
                invokeHttpGet(url + "?resultIndex=0&resultSize=1&format=count", Result.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Result result = actualResponse.getBody();
        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        assertEquals(1, result.getValues().get(0).get(Constants.PROJECT));
    }

    private <T> ResponseEntity<T> invokeHttpGet(final String url, final Class<T> clazz) {
        return restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders(getUsername())), clazz);
    }

    private ResponseEntity<Void> invokeHttpPut(final String url, final Object obj) {
        final HttpEntity<?> httpEntity = getHttpEntity(obj);
        return restTemplate.exchange(url, HttpMethod.PUT, httpEntity, Void.class);
    }

    private HttpEntity<?> getHttpEntity(final Object obj) {
        return new HttpEntity<>(obj, getHttpHeaders(getUsername()));
    }

    private String getUsername() {
        return userCredentials.getUsers().iterator().next().getUsername();
    }

    private String getProjectEndPointUrl() {
        return TestUtils.getBaseUrl(port) + Constants.PROJECT_URL;
    }

    private String getRelationship() throws IOException, Exception {
        return TestUtils.getJsonString(PROJECT_RELATION_SHIP_JSON_FILE);
    }
}
