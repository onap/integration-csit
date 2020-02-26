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

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import javax.ws.rs.core.MediaType;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse2002;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication.AuthTypeEnum;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthenticationParamsBasic;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsFilter;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageChangeNotification;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageOnboardingNotification;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication;
import org.onap.so.svnfm.simulator.services.AdapterSubscriptionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = Constant.NOTIFICATION_BASE_URL, produces = MediaType.APPLICATION_JSON, consumes = MediaType.APPLICATION_JSON)
public class NotificationController {
    @Autowired
    private AdapterSubscriptionManager adapterSubscriptionManager;

    private static final Logger LOGGER = LoggerFactory.getLogger(NotificationController.class);

    public NotificationController() {
    }

    /**
     * Send subscription request
     *
     * @param
     * @return InlineResponse201
     */
    @PostMapping(value = "/subscribe")
    public ResponseEntity subscribeForNotifications(@RequestBody final PkgmSubscriptionRequest pkgmSubscriptionRequest,
        @Value("${spring.security.usercredentials.username}") String username,
        @Value("$spring.security.usercredentials.password}") String password){

        LOGGER.info("Vnf Package Change Notification received: {}", pkgmSubscriptionRequest);

        if(pkgmSubscriptionRequest.getCallbackUri()==null){
            LOGGER.info("Notification does not include call back URI ");
            pkgmSubscriptionRequest.setCallbackUri(Constant.CALL_BACK_URI);

        }

        if(pkgmSubscriptionRequest.getAuthentication()==null) {
            pkgmSubscriptionRequest.setAuthentication(new SubscriptionsAuthentication()
                .addAuthTypeItem(AuthTypeEnum.BASIC)
                .paramsBasic(new SubscriptionsAuthenticationParamsBasic().userName(username).password(password)));

        }
        LOGGER.info("Final Notification being sent : {}", pkgmSubscriptionRequest);

        final InlineResponse2002 response = adapterSubscriptionManager.createSubscription(pkgmSubscriptionRequest);
        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON);
        return new ResponseEntity<>(response, headers, HttpStatus.OK);
    }

    /**
     * Notification relating to VNF Package Change received
     *
     * @param vnfPackageChangeNotification
     * @return Response Code: 204 No Content if Successful, ProblemDetails Object if not.
     */
    @PostMapping(value= "/notifications-VnfPackageChangeNotification")
    public ResponseEntity packageChangeNotificationReceived(@RequestBody VnfPackageChangeNotification vnfPackageChangeNotification){
        LOGGER.info("Vnf Package Change Notification received: {}", vnfPackageChangeNotification);

        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON);
        return new ResponseEntity<>(headers, HttpStatus.NO_CONTENT);
    }

    /**
     * Notification relating to VNF Package Onboarding received
     *
     * @param vnfPackageOnboardingNotification
     * @return Response Code: 204 No Content if Successful, ProblemDetails Object if not.
     */
    @PostMapping(value = "/notifications-VnfPackageOnboardingNotification")
    public ResponseEntity packageOnboardingNotificationReceived(@RequestBody VnfPackageOnboardingNotification vnfPackageOnboardingNotification){
        LOGGER.info("Vnf Package Onboarding Notification received: {}", vnfPackageOnboardingNotification);

        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON);
        return new ResponseEntity<>(headers, HttpStatus.NO_CONTENT);
    }
}
