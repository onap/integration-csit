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

package org.onap.so.sdc.simulator;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Optional;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.onap.so.sdc.simulator.providers.ResourceProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@Configuration
public class SdcSimulatorControllerTest {

    private static final String MOCKER_SDC_CONTROLLER_BEAN = "mockResourceProvider";

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void test_healthCheck_matchContent() {
        final String url = getBaseUrl() + "/healthcheck";
        final ResponseEntity<String> object = restTemplate.getForEntity(url, String.class);

        assertEquals(Constant.HEALTHY, object.getBody());

    }

    @Test
    public void test_getCsar_validCsarId_matchContent() {

        final String url = getBaseUrl() + "/resources/" + Constant.DEFAULT_CSAR_NAME + "/toscaModel";

        final ResponseEntity<byte[]> response = restTemplate.getForEntity(url, byte[].class);

        assertTrue(response.hasBody());
        assertEquals(3982, response.getBody().length);

        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    public void test_getCsar_invalidCsar_internalServerError() {
        final ResourceProvider mockedResourceProvider = Mockito.mock(ResourceProvider.class);
        Mockito.when(mockedResourceProvider.getResource(Mockito.anyString())).thenReturn(Optional.empty());
        final SdcSimulatorController objUnderTest = new SdcSimulatorController(mockedResourceProvider);

        final ResponseEntity<byte[]> response = objUnderTest.getCsar(Constant.DEFAULT_CSAR_NAME);

        assertFalse(response.hasBody());
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
    }

    private String getBaseUrl() {
        return "http://localhost:" + port + Constant.BASE_URL;
    }

}
