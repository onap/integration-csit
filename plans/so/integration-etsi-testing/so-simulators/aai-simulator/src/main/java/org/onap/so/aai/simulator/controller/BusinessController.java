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
package org.onap.so.aai.simulator.controller;

import static org.onap.so.aai.simulator.utils.Constant.BUSINESS_URL;
import static org.onap.so.aai.simulator.utils.Constant.ERROR_MESSAGE;
import static org.onap.so.aai.simulator.utils.Constant.ERROR_MESSAGE_ID;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.so.aai.simulator.service.providers.CustomerServiceProvider;
import org.onap.so.aai.simulator.utils.RequestErrorBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Controller
@RequestMapping(path = BUSINESS_URL)
public class BusinessController {

    private static final Logger LOGGER = LoggerFactory.getLogger(BusinessController.class);
    private final CustomerServiceProvider customerServiceProvider;

    @Autowired
    public BusinessController(final CustomerServiceProvider customerServiceProvider) {
        this.customerServiceProvider = customerServiceProvider;
    }

    @GetMapping(value = "/customers/customer/{global-customer-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCustomer(@PathVariable("global-customer-id") final String globalCustomerId,
            final HttpServletRequest request) {
        LOGGER.info("Will retrieve customer for 'global customer id': {} ...", globalCustomerId);

        final Optional<Customer> optional = customerServiceProvider.getCustomer(globalCustomerId);
        if (optional.isPresent()) {
            final Customer customer = optional.get();
            LOGGER.info("found customer {} in cache", customer);
            return ResponseEntity.ok(customer);
        }

        LOGGER.error("Couldn't find {} in cache", globalCustomerId);
        return new ResponseEntity<>(new RequestErrorBuilder().messageId(ERROR_MESSAGE_ID).text(ERROR_MESSAGE)
                .variables(request.getMethod(), request.getRequestURI()).build(), HttpStatus.NOT_FOUND);
    }

    @PutMapping(value = "/customers/customer/{global-customer-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putCustomer(@RequestBody final Customer customer,
            @PathVariable("global-customer-id") final String globalCustomerId, final HttpServletRequest request) {
        LOGGER.info("Will put customer for 'global customer id': {} ...", globalCustomerId);

        if (customer.getResourceVersion() == null || customer.getResourceVersion().isEmpty()) {
            customer.setResourceVersion(System.currentTimeMillis() + "");

        }
        customerServiceProvider.putCustomer(globalCustomerId, customer);
        return ResponseEntity.accepted().build();

    }

    @GetMapping(
            value = "/customers/customer/{global-customer-id}/service-subscriptions/service-subscription/{service-type}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCustomer(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType, final HttpServletRequest request) {
        LOGGER.info("Will retrieve service subscription for 'global customer id': {} and 'service type': {} ...",
                globalCustomerId, serviceType);

        final Optional<ServiceSubscription> optional =
                customerServiceProvider.getServiceSubscription(globalCustomerId, serviceType);
        if (optional.isPresent()) {
            final ServiceSubscription serviceSubscription = optional.get();
            LOGGER.info("found service subscription  {} in cache", serviceSubscription);
            return ResponseEntity.ok(serviceSubscription);
        }

        LOGGER.error("Couldn't find {} in cache", globalCustomerId);
        return new ResponseEntity<>(new RequestErrorBuilder().messageId(ERROR_MESSAGE_ID).text(ERROR_MESSAGE)
                .variables(request.getMethod(), request.getRequestURI()).build(), HttpStatus.NOT_FOUND);
    }


}
