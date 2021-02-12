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

package org.onap.so.svnfm.simulator.controller;

import javax.ws.rs.core.MediaType;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse201;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication.AuthTypeEnum;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthenticationParamsBasic;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageChangeNotification;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageOnboardingNotification;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.onap.so.svnfm.simulator.services.SubscriptionManager;
import org.onap.so.svnfm.simulator.services.providers.VnfPkgOnboardingNotificationCacheServiceProviderImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Optional;

/**
 * @author Eoin Hanan (eoin.hanan@est.tech)
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 *
 */
@RestController
@RequestMapping(path = Constant.PACKAGE_MANAGEMENT_BASE_URL, produces = MediaType.APPLICATION_JSON, consumes = MediaType.APPLICATION_JSON)
public class SubscriptionNotificationController {

    private static final Logger logger = LoggerFactory.getLogger(SubscriptionNotificationController.class);
    private final Gson gson;
    @Autowired
    private SubscriptionManager subscriptionManager;
    @Autowired
    private VnfPkgOnboardingNotificationCacheServiceProviderImpl vnfPkgOnboardingNotificationCacheServiceProvider;

    @Autowired
    public SubscriptionNotificationController() {
        this.gson = new GsonBuilder().registerTypeAdapter(LocalDateTime.class, new LocalDateTimeTypeAdapter()).create();
    }

    @Value("${spring.security.usercredentials[0].username}")
    private String username;
    @Value("${spring.security.usercredentials[0].password}")
    private String password;

    @GetMapping(produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<Void> testEndpoint() {
        logger.info("Testing SubscriptionNotification Endpoint");
        return ResponseEntity.noContent().build();
    }

    /**
     * Send subscription request
     *
     * @param pkgmSubscriptionRequest The subscription request
     * @return
     */
    @PostMapping(value = Constant.SUBSCRIPTION_ENDPOINT, produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> subscribeForNotifications(@RequestBody final PkgmSubscriptionRequest pkgmSubscriptionRequest){
        logger.info("Vnf Package Subscription Request received:\n{}", pkgmSubscriptionRequest);

        if(pkgmSubscriptionRequest.getCallbackUri()==null){
            logger.info("Subscription Request does not include call back URI ");
            pkgmSubscriptionRequest.setCallbackUri(Constant.PACKAGE_MANAGEMENT_BASE_URL + Constant.NOTIFICATION_ENDPOINT);
        }

        if(pkgmSubscriptionRequest.getAuthentication()==null) {
            pkgmSubscriptionRequest.setAuthentication(new SubscriptionsAuthentication()
                .addAuthTypeItem(AuthTypeEnum.BASIC)
                .paramsBasic(new SubscriptionsAuthenticationParamsBasic().userName(username).password(password)));

        }
        logger.info("Final Request being sent:\n{}", pkgmSubscriptionRequest);

        final InlineResponse201 response = subscriptionManager.createSubscription(pkgmSubscriptionRequest);
        logger.info("Response is:\n{}", response);

        return ResponseEntity.ok().body(response);
    }

    /**
     * Endpoint to receive VNF package notifications
     *
     * @param notification The notification received
     * @return
     */
    @PostMapping(value = Constant.NOTIFICATION_ENDPOINT, produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postVnfPackageNotification(@RequestBody final Object notification){
        logger.info("Vnf Notification received:\n{}", notification);
        final String notificationString = gson.toJson(notification);
        addNotificationObjectToCache(notificationString);
        return ResponseEntity.noContent().build();
    }

    /**
     * Testing endpoint for checking that notifications have been received
     *
     * @param vnfPkgId
     * @return
     */
    @GetMapping(value = Constant.NOTIFICATION_CACHE_TEST_ENDPOINT)
    public ResponseEntity<?> getVnfPackageNotification(@PathVariable("vnfPkgId") final String vnfPkgId) {
        logger.info("Getting notification with vnfPkgId: {}", vnfPkgId);
        final Optional<VnfPackageOnboardingNotification> optionalVnfPackageOnboardingNotification =
                vnfPkgOnboardingNotificationCacheServiceProvider.getVnfPkgOnboardingNotification(vnfPkgId);
        if(optionalVnfPackageOnboardingNotification.isPresent()) {
            VnfPackageOnboardingNotification vnfPackageOnboardingNotification =
                    optionalVnfPackageOnboardingNotification.get();
            logger.info("Return notification with vnfPkgId: {} and body {}", vnfPkgId, vnfPackageOnboardingNotification);
            return ResponseEntity.ok().body(vnfPackageOnboardingNotification);
        }
        final String errorMessage = "No notification found with vnfPkgId: " + vnfPkgId;
        logger.error(errorMessage);
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorMessage);
    }

    private void addNotificationObjectToCache(final String notification) {
        logger.info("addNotificationObjectToCache(): {}", notification);
        final String notificationType = getNotificationType(notification);
        if (VnfPackageOnboardingNotification.NotificationTypeEnum.VNFPACKAGEONBOARDINGNOTIFICATION.getValue()
                .equals(notificationType)) {
            final VnfPackageOnboardingNotification pkgOnboardingNotification =
                    gson.fromJson(notification, VnfPackageOnboardingNotification.class);
            logger.info("Onboarding notification received:\n{}", pkgOnboardingNotification);
            final String vnfPkgId = pkgOnboardingNotification.getVnfPkgId();
            vnfPkgOnboardingNotificationCacheServiceProvider.addVnfPkgOnboardingNotification(vnfPkgId, pkgOnboardingNotification);
        } else if (VnfPackageChangeNotification.NotificationTypeEnum.VNFPACKAGECHANGENOTIFICATION.getValue()
                .equals(notificationType)) {
            final VnfPackageChangeNotification pkgChangeNotification =
                    gson.fromJson(notification, VnfPackageChangeNotification.class);
            logger.info("Change notification received:\n{}", pkgChangeNotification);
        } else {
            final String errorMessage = "An error occurred.  Notification type not supported for: " + notificationType;
            logger.error(errorMessage);
            throw new RuntimeException(errorMessage);
        }
    }

    private String getNotificationType(final String notification) {
        try {
            logger.info("getNotificationType() notification: {}", notification);
            final JsonParser parser = new JsonParser();
            final JsonObject element = (JsonObject) parser.parse(notification);
            return element.get("notificationType").getAsString();
        } catch (final Exception e) {
            logger.error("An error occurred processing notificiation: {}", e.getMessage());
        }
        throw new RuntimeException(
                "Unable to parse notification type in object \n" + notification);
    }

    public static class LocalDateTimeTypeAdapter extends TypeAdapter<LocalDateTime> {

        private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        @Override
        public void write(final JsonWriter out, final LocalDateTime localDateTime) throws IOException {
            if (localDateTime == null) {
                out.nullValue();
            } else {
                out.value(FORMATTER.format(localDateTime));
            }
        }

        @Override
        public LocalDateTime read(final JsonReader in) throws IOException {
            switch (in.peek()) {
                case NULL:
                    in.nextNull();
                    return null;
                default:
                    final String dateTime = in.nextString();
                    return LocalDateTime.parse(dateTime, FORMATTER);
            }
        }
    }

}
