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

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
public class TestUtils {
    private static final String PASSWORD = "Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U";


    private TestUtils() {}

    public static String getRequestInput() throws IOException {
        return getFileAsString(getFile("test-data/input.json").toPath());
    }

    public static String getVnfRequestInput() throws IOException {
        return getFileAsString(getFile("test-data/vnfInput.json").toPath());
    }

    public static String getVnfRequestWithSvcActionActivateInput() throws IOException {
        return getFileAsString(getFile("test-data/activateVnfInput.json").toPath());
    }

    public static String getInvalidRequestInput() throws IOException {
        return getFileAsString(getFile("test-data/InvalidInput.json").toPath());
    }

    public static String getVnfRequestWithRequestActionDeleteVnfInput() throws IOException {
        return getFileAsString(getFile("test-data/deleteVnfInput.json").toPath());
    }

    public static String getServiceRequestWithRequestActionDeleteServiceInput() throws IOException {
        return getFileAsString(getFile("test-data/deleteServiceInput.json").toPath());
    }

    public static String getServiceRequestWithRequestActionDeleteServiceAndSvcActionDeactivateInput()
            throws IOException {
        return getFileAsString(getFile("test-data/deactivateServiceInput.json").toPath());
    }


    public static String getFileAsString(final Path path) throws IOException {
        return new String(Files.readAllBytes(path));
    }

    public static File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    public static HttpHeaders getHttpHeaders(final String username) {
        final HttpHeaders requestHeaders = new HttpHeaders();
        requestHeaders.add("Authorization", getBasicAuth(username));
        requestHeaders.setContentType(MediaType.APPLICATION_JSON);
        return requestHeaders;
    }

    public static String getBasicAuth(final String username) {
        return "Basic " + new String(Base64.getEncoder().encodeToString((username + ":" + PASSWORD).getBytes()));
    }

}
