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

package org.onap.so.svnfm.simulator.controllers;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse201;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsFilter1;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageOnboardingNotification;
import org.onap.so.svnfm.simulator.config.SvnfmApplication;
import org.onap.so.svnfm.simulator.controller.SubscriptionNotificationController;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.json.GsonHttpMessageConverter;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;
import java.time.LocalDateTime;

import static org.junit.Assert.assertEquals;
import static org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsFilter.NotificationTypesEnum.VNFPACKAGECHANGENOTIFICATION;
import static org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsFilter.NotificationTypesEnum.VNFPACKAGEONBOARDINGNOTIFICATION;
import static org.onap.so.svnfm.simulator.config.SslBasedRestTemplateConfiguration.SSL_BASED_CONFIGURABLE_REST_TEMPLATE;
import static org.onap.so.svnfm.simulator.constants.Constant.NOTIFICATION_ENDPOINT;
import static org.onap.so.svnfm.simulator.constants.Constant.PACKAGE_MANAGEMENT_BASE_URL;
import static org.onap.so.svnfm.simulator.constants.Constant.SUBSCRIPTION_ENDPOINT;
import static org.onap.so.svnfm.simulator.constants.Constant.VNFM_ADAPTER_SUBSCRIPTION_ENDPOINT;
import static org.onap.so.svnfm.simulator.utils.TestUtils.getBaseUrl;
import static org.onap.so.svnfm.simulator.utils.TestUtils.getBasicAuth;
import static org.onap.so.svnfm.simulator.utils.TestUtils.getHttpHeaders;
import static org.onap.so.svnfm.simulator.utils.TestUtils.getNotification;
import static org.onap.so.svnfm.simulator.utils.TestUtils.getSubscriptionRequest;
import static org.slf4j.LoggerFactory.getLogger;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

/**
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 */
@RunWith(SpringRunner.class)
@SpringBootTest(classes = SvnfmApplication.class, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class TestSubscriptionNotificationController {

    private static final Logger LOGGER = getLogger(TestSubscriptionNotificationController.class);
    private static final String SOL003_SUBSCRIPTION_URL = "http://so-vnfm-adapter.onap:9092" + VNFM_ADAPTER_SUBSCRIPTION_ENDPOINT;

    @LocalServerPort
    private int port;

    @Autowired @Qualifier(SSL_BASED_CONFIGURABLE_REST_TEMPLATE)
    private RestTemplate restTemplate;
    private MockRestServiceServer mockRestServiceServer;

    private TestRestTemplate testRestTemplate;

    private Gson gson;
    private String vnfmSimulatorCallbackUrl;

    @Before
    public void setup() {
        mockRestServiceServer = MockRestServiceServer.bindTo(restTemplate).build();
        gson = new GsonBuilder().registerTypeAdapter(LocalDateTime.class,
                new SubscriptionNotificationController.LocalDateTimeTypeAdapter()).create();
        vnfmSimulatorCallbackUrl = getBaseUrl(port) + PACKAGE_MANAGEMENT_BASE_URL + NOTIFICATION_ENDPOINT;
        testRestTemplate = new TestRestTemplate(
                new RestTemplateBuilder().additionalMessageConverters(new GsonHttpMessageConverter(gson)));
    }

    @After
    public void teardown() {
        mockRestServiceServer.reset();
    }

    @Test
    public void testGetFromEndpoint_Success() {
        final ResponseEntity<?> responseEntity = checkGetFromTestEndpoint();
        assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
    }

    @Test
    public void testPostOnboardingSubscriptionRequest_Success() throws Exception {
        final PkgmSubscriptionRequest pkgmSubscriptionRequest =
                gson.fromJson(getSubscriptionRequest(VNFPACKAGEONBOARDINGNOTIFICATION), PkgmSubscriptionRequest.class);
        pkgmSubscriptionRequest.setCallbackUri(vnfmSimulatorCallbackUrl);
        final InlineResponse201 inlineResponse =
                new InlineResponse201().id("subscriptionId").filter(new SubscriptionsFilter1())
                        .callbackUri("callbackUri");

        mockRestServiceServer.expect(requestTo(SOL003_SUBSCRIPTION_URL)).andExpect(method(HttpMethod.POST))
                .andExpect(content().json(gson.toJson(pkgmSubscriptionRequest)))
                .andRespond(withSuccess(gson.toJson(inlineResponse), APPLICATION_JSON));

        final ResponseEntity<?> responseEntity = postSubscriptionRequest(pkgmSubscriptionRequest);
        final InlineResponse201 responseEntityBody = (InlineResponse201) responseEntity.getBody();
        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        assertEquals(inlineResponse, responseEntityBody);
    }

    @Test
    public void testPostChangeSubscriptionRequest_Success() throws Exception {
        final PkgmSubscriptionRequest pkgmSubscriptionRequest =
                gson.fromJson(getSubscriptionRequest(VNFPACKAGECHANGENOTIFICATION), PkgmSubscriptionRequest.class);
        pkgmSubscriptionRequest.setCallbackUri(vnfmSimulatorCallbackUrl);
        final InlineResponse201 inlineResponse =
                new InlineResponse201().id("subscriptionId").filter(new SubscriptionsFilter1())
                        .callbackUri("callbackUri");

        mockRestServiceServer.expect(requestTo(SOL003_SUBSCRIPTION_URL)).andExpect(method(HttpMethod.POST))
                .andExpect(content().json(gson.toJson(pkgmSubscriptionRequest)))
                .andRespond(withSuccess(gson.toJson(inlineResponse), APPLICATION_JSON));

        final ResponseEntity<?> responseEntity = postSubscriptionRequest(pkgmSubscriptionRequest);
        final InlineResponse201 responseEntityBody = (InlineResponse201) responseEntity.getBody();
        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        assertEquals(inlineResponse, responseEntityBody);
    }

    @Test
    public void testNotificationEndpoint_Success() throws Exception {
        final VnfPackageOnboardingNotification vnfPackageOnboardingNotification =
                gson.fromJson(getNotification(VNFPACKAGEONBOARDINGNOTIFICATION),
                        VnfPackageOnboardingNotification.class);
        final ResponseEntity<?> responseEntity = postNotification(vnfPackageOnboardingNotification);
        assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());
    }

    private ResponseEntity<Void> checkGetFromTestEndpoint() {
        LOGGER.info("checkGetFromTestEndpoint() method...");
        final String vnfmSimulatorTestEndpoint = getBaseUrl(port) + PACKAGE_MANAGEMENT_BASE_URL;
        final String authHeader = getBasicAuth("vnfm", "password1$");
        final HttpHeaders headers = getHttpHeaders(authHeader);
        final HttpEntity<?> request = new HttpEntity<>(headers);

        LOGGER.info("sending request {} to: {}", request, vnfmSimulatorTestEndpoint);
        return testRestTemplate.exchange(vnfmSimulatorTestEndpoint, HttpMethod.GET, request, Void.class);
    }

    private ResponseEntity<?> postSubscriptionRequest(final PkgmSubscriptionRequest subscriptionRequest) {
        LOGGER.info("postSubscriptionRequest() method...");
        final String vnfmSimulatorSubscribeEndpoint =
                getBaseUrl(port) + PACKAGE_MANAGEMENT_BASE_URL + SUBSCRIPTION_ENDPOINT;
        final String authHeader = getBasicAuth("vnfm", "password1$");
        final HttpHeaders headers = getHttpHeaders(authHeader);
        final HttpEntity<?> request = new HttpEntity<>(subscriptionRequest, headers);

        LOGGER.info("sending request {} to: {}", request, vnfmSimulatorSubscribeEndpoint);
        return testRestTemplate
                .exchange(vnfmSimulatorSubscribeEndpoint, HttpMethod.POST, request, InlineResponse201.class);
    }

    private ResponseEntity<?> postNotification(final Object notification) {
        LOGGER.info("postNotification method...");
        final String authHeader = getBasicAuth("vnfm", "password1$");
        final HttpHeaders headers = getHttpHeaders(authHeader);
        final HttpEntity<?> request = new HttpEntity<>(notification, headers);

        LOGGER.info("sending request {} to: {}", request, vnfmSimulatorCallbackUrl);
        return testRestTemplate.exchange(vnfmSimulatorCallbackUrl, HttpMethod.POST, request, Void.class);
    }
}
