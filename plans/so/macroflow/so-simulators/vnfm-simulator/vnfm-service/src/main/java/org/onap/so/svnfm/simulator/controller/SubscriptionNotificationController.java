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
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.InlineResponse201;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.PkgmSubscriptionRequest;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthentication.AuthTypeEnum;
import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.model.SubscriptionsAuthenticationParamsBasic;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.onap.so.svnfm.simulator.services.SubscriptionManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author Eoin Hanan (eoin.hanan@est.tech)
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 *
 */
@RestController
@RequestMapping(path = Constant.PACKAGE_MANAGEMENT_BASE_URL, produces = MediaType.APPLICATION_JSON, consumes = MediaType.APPLICATION_JSON)
public class SubscriptionNotificationController {
    @Autowired
    private SubscriptionManager subscriptionManager;

    private static final Logger logger = LoggerFactory.getLogger(SubscriptionNotificationController.class);

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
    public ResponseEntity<?> postVnfPackageNotification(@RequestBody Object notification){
        logger.info("Vnf Notification received:\n{}", notification);
        return ResponseEntity.noContent().build();
    }

}
