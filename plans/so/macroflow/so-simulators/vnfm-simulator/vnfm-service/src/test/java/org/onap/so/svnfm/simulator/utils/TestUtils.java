/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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
package org.onap.so.svnfm.simulator.utils;

import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsFilter;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import javax.ws.rs.core.MediaType;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import org.apache.commons.codec.binary.Base64;

/**
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 *
 */
public class TestUtils {

    public static String getBasicAuth(final String username, final String password) {
        final String auth = username + ":" + password;
        return "Basic " + new String(Base64.encodeBase64(auth.getBytes(StandardCharsets.ISO_8859_1)));
    }

    public static HttpHeaders getHttpHeaders(final String authHeader) {
        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.AUTHORIZATION, authHeader);
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON);
        headers.add(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON);
        return headers;
    }

    public static File getFile(final String file) throws IOException {
        return new ClassPathResource(file).getFile();
    }

    public static String getJsonString(final String file) throws IOException {
        return new String(Files.readAllBytes(getFile(file).toPath()));
    }

    public static String getBaseUrl(final int port) {
        return "http://localhost:" + port;
    }

    public static String getSubscriptionRequest(final SubscriptionsFilter.NotificationTypesEnum notificationType) throws Exception {
        switch (notificationType) {
            case VNFPACKAGECHANGENOTIFICATION:
                return getJsonString("test-data/pkg-subscription-request-change.json");
            case VNFPACKAGEONBOARDINGNOTIFICATION:
                return getJsonString("test-data/pkg-subscription-request-onboarding.json");
            default:
                return null;
        }
    }

    public static String getNotification(final SubscriptionsFilter.NotificationTypesEnum notificationType) throws Exception {
        switch (notificationType) {
            case VNFPACKAGECHANGENOTIFICATION:
                return getJsonString("test-data/vnf-package-change-notification.json");
            case VNFPACKAGEONBOARDINGNOTIFICATION:
                return getJsonString("test-data/vnf-package-onboarding-notification.json");
            default:
                return null;
        }
    }

    private TestUtils() {}

}
