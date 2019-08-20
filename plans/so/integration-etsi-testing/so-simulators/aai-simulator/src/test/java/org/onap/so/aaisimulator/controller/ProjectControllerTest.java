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
import org.onap.aai.domain.yang.Project;
import org.onap.so.aaisimulator.models.Results;
import org.onap.so.aaisimulator.service.providers.ProjectCacheServiceProvider;
import org.onap.so.aaisimulator.utils.Constants;
import org.onap.so.aaisimulator.utils.TestRestTemplateService;
import org.onap.so.aaisimulator.utils.TestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
public class ProjectControllerTest extends AbstractSpringBootTest {

    private static final String PROJECT_NAME_VALUE = "PROJECT_NAME_VALUE";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplateService testRestTemplateService;

    @Autowired
    private ProjectCacheServiceProvider cacheServiceProvider;

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

    @Test
    public void test_putProject_successfullyAddedToCache() throws Exception {
        final String url = getUrl(Constants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Project> actualResponse = testRestTemplateService.invokeHttpGet(url, Project.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Project actualProject = actualResponse.getBody();
        assertEquals(PROJECT_NAME_VALUE, actualProject.getProjectName());
        assertNotNull(actualProject.getResourceVersion());

    }

    @Test
    public void test_putProjectRelationShip_successfullyAddedToCache() throws Exception {
        final String url = getUrl(Constants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);
        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final String projectRelationshipUrl = getUrl(Constants.PROJECT_URL, PROJECT_NAME_VALUE, RELATIONSHIP_URL);

        final ResponseEntity<Void> putResponse = testRestTemplateService.invokeHttpPut(projectRelationshipUrl,
                TestUtils.getBusinessProjectRelationship(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, putResponse.getStatusCode());

        final ResponseEntity<Project> actualResponse = testRestTemplateService.invokeHttpGet(url, Project.class);

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
        final String url = getUrl(Constants.PROJECT_URL, PROJECT_NAME_VALUE);
        final ResponseEntity<Void> actual =
                testRestTemplateService.invokeHttpPut(url, TestUtils.getBusinessProject(), Void.class);

        assertEquals(HttpStatus.ACCEPTED, actual.getStatusCode());

        final ResponseEntity<Results> actualResponse =
                testRestTemplateService.invokeHttpGet(url + "?resultIndex=0&resultSize=1&format=count", Results.class);

        assertEquals(HttpStatus.OK, actualResponse.getStatusCode());
        assertTrue(actualResponse.hasBody());
        final Results result = actualResponse.getBody();
        assertNotNull(result.getValues());
        assertFalse(result.getValues().isEmpty());
        assertEquals(1, result.getValues().get(0).get(Constants.PROJECT));
    }

}
