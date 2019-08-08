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
package org.onap.so.sdncsimulator.controller;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.sdnc.northbound.client.model.GenericResourceApiInstanceReference;
import org.onap.so.sdncsimulator.models.InputRequest;
import org.onap.so.sdncsimulator.models.Output;
import org.onap.so.sdncsimulator.models.OutputRequest;
import org.onap.so.sdncsimulator.providers.ServiceOperationsCacheServiceProvider;
import org.onap.so.sdncsimulator.utils.Constants;
import org.onap.so.simulator.model.UserCredentials;
import org.springframework.beans.factory.annotation.Autowired;
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
public class OperationsControllerTest {

    private static final String SVC_REQUEST_ID = "04fc9f50-87b8-430d-a232-ef24bd6c4150";

    private static final String SERVICE_INSTANCE_ID = "ccece8fe-13da-456a-baf6-41b3a4a2bc2b";

    private static final String SERVICE_TOPOLOGY_OPERATION_URL = "/GENERIC-RESOURCE-API:service-topology-operation/";

    private static final String PASSWORD = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private ServiceOperationsCacheServiceProvider cacheServiceProvider;

    @Autowired
    private UserCredentials userCredentials;


    @Test
    public void test_postServiceOperationInformation_successfullyAddedToCache() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        assertTrue(responseEntity.hasBody());

        final OutputRequest actualOutputRequest = responseEntity.getBody();
        assertNotNull(actualOutputRequest);

        final Output actualObject = actualOutputRequest.getOutput();

        assertNotNull(actualObject);
        assertEquals(HttpStatus.OK.toString(), actualObject.getResponseCode());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertNotNull(actualObject.getServiceResponseInformation());

        final GenericResourceApiInstanceReference acutalReference = actualObject.getServiceResponseInformation();
        assertEquals(Constants.RESTCONF_CONFIG_END_POINT + SERVICE_INSTANCE_ID, acutalReference.getObjectPath());
        assertEquals(SERVICE_INSTANCE_ID, acutalReference.getInstanceId());
        assertTrue(
                cacheServiceProvider.getGenericResourceApiServiceModelInfrastructure(SERVICE_INSTANCE_ID).isPresent());
    }

    @Test
    public void test_postServiceOperationInformation_NullInputRequest_badRequest() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(new InputRequest<>(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.BAD_REQUEST, responseEntity.getStatusCode());
    }

    @Test
    public void test_postServiceOperationInformation_NullServiceInstanceId_badRequest() throws Exception {

        final HttpEntity<?> httpEntity = new HttpEntity<>(getInvalidRequestInput(), getHttpHeaders());
        final ResponseEntity<OutputRequest> responseEntity =
                restTemplate.exchange(getUrl(), HttpMethod.POST, httpEntity, OutputRequest.class);

        assertEquals(HttpStatus.BAD_REQUEST, responseEntity.getStatusCode());
        assertTrue(responseEntity.hasBody());

        final OutputRequest actualOutputRequest = responseEntity.getBody();
        assertNotNull(actualOutputRequest);

        final Output actualObject = actualOutputRequest.getOutput();
        assertNotNull(actualObject);
        assertEquals(HttpStatus.BAD_REQUEST.toString(), actualObject.getResponseCode());
        assertEquals(SVC_REQUEST_ID, actualObject.getSvcRequestId());
        assertEquals(Constants.YES, actualObject.getAckFinalIndicator());

    }

    private HttpHeaders getHttpHeaders() {
        return getHttpHeaders(userCredentials.getUsers().iterator().next().getUsername());
    }

    private String getUrl() {
        return "http://localhost:" + port + Constants.OPERATIONS_URL + SERVICE_TOPOLOGY_OPERATION_URL;
    }

    private String getRequestInput() throws IOException {
        return getFileAsString(getFile("test-data/input.json").toPath());
    }

    private String getInvalidRequestInput() throws IOException {
        return getFileAsString(getFile("test-data/InvalidInput.json").toPath());
    }

    private String getFileAsString(final Path path) throws IOException {
        return new String(Files.readAllBytes(path));
    }

    private File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    private HttpHeaders getHttpHeaders(final String username) {
        final HttpHeaders requestHeaders = new HttpHeaders();
        requestHeaders.add("Authorization", getBasicAuth(username));
        requestHeaders.setContentType(MediaType.APPLICATION_JSON);
        return requestHeaders;
    }

    private String getBasicAuth(final String username) {
        return "Basic " + new String(Base64.getEncoder().encodeToString((username + ":" + PASSWORD).getBytes()));
    }

    @After
    public void after() {
        cacheServiceProvider.clearAll();
    }

}
