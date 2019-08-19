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
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.onap.so.aaisimulator.utils.TestConstants.LINE_OF_BUSINESS_NAME;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.aai.domain.yang.LineOfBusiness;
import org.onap.so.aaisimulator.service.providers.LinesOfBusinessCacheServiceProvider;
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

        final ResponseEntity<LineOfBusiness> response = testRestTemplateService.invokeHttpGet(url, LineOfBusiness.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());

        assertTrue(response.hasBody());

        final LineOfBusiness actualLineOfBusiness = response.getBody();
        assertEquals(LINE_OF_BUSINESS_NAME, actualLineOfBusiness.getLineOfBusinessName());
        assertNotNull("resource version should not be null", actualLineOfBusiness.getResourceVersion());

    }

    private String getUrl(final String... urls) {
        return TestUtils.getUrl(port, urls);
    }
}
