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
package org.onap.so.sdcsimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import java.util.Base64;
import java.util.Set;
import java.util.UUID;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.so.sdcsimulator.models.Metadata;
import org.onap.so.sdcsimulator.models.ResourceAssetInfo;
import org.onap.so.sdcsimulator.models.ResourceMetadata;
import org.onap.so.sdcsimulator.models.ServiceAssetInfo;
import org.onap.so.sdcsimulator.models.ServiceMetadata;
import org.onap.so.sdcsimulator.utils.Constants;
import org.onap.so.simulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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
public class CatalogControllerTest {

    private static final String SUB_CATEGORY = "Network Service";

    private static final String DISTRIBUTION_STATUS = "DISTRIBUTED";

    private static final String SERVICE_ID = "9bb8c882-44a1-4b67-a12c-5a998e18d6ba";

    private static final String RESOURCE_ID = "73522444-e8e9-49c1-be29-d355800aa349";

    private static final String PASSWORD = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserCredentials userCredentials;

    @Test
    public void test_getCsar_validCsarId_matchContent() {

        final String url = getBaseUrl() + "/resources/" + RESOURCE_ID + "/toscaModel";

        final ResponseEntity<byte[]> response =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), byte[].class);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());
        assertEquals(117247, response.getBody().length);

    }

    @Test
    public void test_getResources_validResourcesFromClassPath() {

        final ResponseEntity<Set<ResourceAssetInfo>> response =
                restTemplate.exchange(getBaseUrl() + "/resources", HttpMethod.GET, new HttpEntity<>(getHttpHeaders()),
                        new ParameterizedTypeReference<Set<ResourceAssetInfo>>() {});

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());
        assertEquals(1, response.getBody().size());
        assertEquals(SUB_CATEGORY, response.getBody().iterator().next().getSubCategory());

    }

    @Test
    public void test_getServices_validServicesFromClassPath() {

        final ResponseEntity<Set<ServiceAssetInfo>> response =
                restTemplate.exchange(getBaseUrl() + "/services", HttpMethod.GET, new HttpEntity<>(getHttpHeaders()),
                        new ParameterizedTypeReference<Set<ServiceAssetInfo>>() {});

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());
        assertEquals(1, response.getBody().size());
        assertEquals(DISTRIBUTION_STATUS, response.getBody().iterator().next().getDistributionStatus());

    }

    @Test
    public void test_getResourceCsar_invalidCsar_internalServerError() {
        final String url = getBaseUrl() + "/resources/" + UUID.randomUUID().toString() + "/toscaModel";

        final ResponseEntity<byte[]> response =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), byte[].class);


        assertFalse(response.hasBody());
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
    }

    @Test
    public void test_getResourceMetadata_validMetadataFileInClasspath_matchContent() {

        final String url = getBaseUrl() + "/resources/" + RESOURCE_ID + "/metadata";

        final ResponseEntity<ResourceMetadata> response =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), ResourceMetadata.class);


        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());
        final ResourceMetadata actual = response.getBody();
        assertEquals(8, actual.getResources().size());
        assertEquals(3, actual.getArtifacts().size());
        assertEquals(SUB_CATEGORY, actual.getSubCategory());

    }

    @Test
    public void test_getServiceMetadata_validMetadataFileInClasspath_matchContent() {

        final String url = getBaseUrl() + "/services/" + SERVICE_ID + "/metadata";

        final ResponseEntity<ServiceMetadata> response =
                restTemplate.exchange(url, HttpMethod.GET, new HttpEntity<>(getHttpHeaders()), ServiceMetadata.class);


        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertTrue(response.hasBody());
        final ServiceMetadata actual = response.getBody();
        assertEquals(1, actual.getResources().size());
        assertEquals(1, actual.getArtifacts().size());
        assertEquals(DISTRIBUTION_STATUS, actual.getDistributionStatus());

    }


    private String getBaseUrl() {
        return "http://localhost:" + port + Constants.CATALOG_URL;
    }

    private HttpHeaders getHttpHeaders() {
        final HttpHeaders requestHeaders = new HttpHeaders();
        requestHeaders.add("Authorization", getBasicAuth(userCredentials.getUsers().get(0).getUsername()));
        requestHeaders.setContentType(MediaType.APPLICATION_JSON);
        return requestHeaders;
    }

    private String getBasicAuth(final String username) {
        return "Basic " + new String(Base64.getEncoder().encodeToString((username + ":" + PASSWORD).getBytes()));
    }

}
