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

import static org.onap.so.aai.simulator.utils.Constants.CUSTOMER_URL;
import static org.onap.so.aai.simulator.utils.Constants.SERVICE_RESOURCE_TYPE;
import static org.onap.so.aai.simulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.so.aai.simulator.utils.Utils.getRequestErrorResponseEntity;
import static org.onap.so.aai.simulator.utils.Utils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.so.aai.simulator.models.NodeServiceInstance;
import org.onap.so.aai.simulator.service.providers.CustomerCacheServiceProvider;
import org.onap.so.aai.simulator.service.providers.NodesCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Controller
@RequestMapping(path = CUSTOMER_URL)
public class BusinessController {

    private static final String SERVICE_SUBSCRIPTION = "service-subscription";
    private static final String CUSTOMER_TYPE = "Customer";
    private static final Logger LOGGER = LoggerFactory.getLogger(BusinessController.class);
    private final CustomerCacheServiceProvider cacheServiceProvider;
    private final NodesCacheServiceProvider nodesCacheServiceProvider;

    @Autowired
    public BusinessController(final CustomerCacheServiceProvider cacheServiceProvider,
            final NodesCacheServiceProvider nodesCacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
        this.nodesCacheServiceProvider = nodesCacheServiceProvider;
    }

    @GetMapping(value = "{global-customer-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCustomer(@PathVariable("global-customer-id") final String globalCustomerId,
            final HttpServletRequest request) {
        LOGGER.info("Will retrieve customer for 'global customer id': {} ...", globalCustomerId);

        final Optional<Customer> optional = cacheServiceProvider.getCustomer(globalCustomerId);
        if (optional.isPresent()) {
            final Customer customer = optional.get();
            LOGGER.info("found customer {} in cache", customer);
            return ResponseEntity.ok(customer);
        }

        LOGGER.error("Couldn't find {} in cache", globalCustomerId);
        return getRequestErrorResponseEntity(request, CUSTOMER_TYPE);
    }

    @PutMapping(value = "/{global-customer-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putCustomer(@RequestBody final Customer customer,
            @PathVariable("global-customer-id") final String globalCustomerId, final HttpServletRequest request) {
        LOGGER.info("Will put customer for 'global customer id': {} ...", globalCustomerId);

        if (customer.getResourceVersion() == null || customer.getResourceVersion().isEmpty()) {
            customer.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putCustomer(globalCustomerId, customer);
        return ResponseEntity.accepted().build();

    }

    @GetMapping(value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCustomer(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType, final HttpServletRequest request) {
        LOGGER.info("Will retrieve service subscription for 'global customer id': {} and 'service type': {} ...",
                globalCustomerId, serviceType);

        final Optional<ServiceSubscription> optional =
                cacheServiceProvider.getServiceSubscription(globalCustomerId, serviceType);
        if (optional.isPresent()) {
            final ServiceSubscription serviceSubscription = optional.get();
            LOGGER.info("found service subscription  {} in cache", serviceSubscription);
            return ResponseEntity.ok(serviceSubscription);
        }

        LOGGER.error("Couldn't find 'global customer id': {} and 'service type': {} in cache", globalCustomerId,
                serviceType);
        return getRequestErrorResponseEntity(request, SERVICE_SUBSCRIPTION);
    }

    @PutMapping(value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putServiceSubscription(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType,
            @RequestBody final ServiceSubscription serviceSubscription, final HttpServletRequest request) {
        LOGGER.info("Will add service subscription for 'global customer id': {} and 'service type': {} ...",
                globalCustomerId, serviceType);

        if (cacheServiceProvider.putServiceSubscription(globalCustomerId, serviceType, serviceSubscription)) {
            LOGGER.info("Successfully add service subscription in cache ...");
            return ResponseEntity.accepted().build();
        }

        LOGGER.error("Couldn't add service subscription using 'global customer id': {} and 'service type': {}",
                globalCustomerId, serviceType);
        return getRequestErrorResponseEntity(request, SERVICE_SUBSCRIPTION);
    }
    
    @GetMapping(
            value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getSericeInstances(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType,
            @RequestParam(name = "service-instance-name") final String serviceInstanceName,
            @RequestParam(name = "depth", required = false) final Integer depth, final HttpServletRequest request) {

        LOGGER.info(
                "Will retrieve service instances for 'global customer id': {}, 'service type': {} and 'service instance name: '{} with depth: {}...",
                globalCustomerId, serviceType, serviceInstanceName, depth);

        final Optional<ServiceInstances> optional =
                cacheServiceProvider.getServiceInstances(globalCustomerId, serviceType, serviceInstanceName);
        if (optional.isPresent()) {
            final ServiceInstances serviceInstances = optional.get();
            LOGGER.info("found service instance  {} in cache", serviceInstances);
            return ResponseEntity.ok(serviceInstances);
        }
        LOGGER.error(
                "Couldn't find 'global customer id': {}, 'service type': {} and 'service instance name': {} with depth: {} in cache",
                globalCustomerId, serviceType, serviceInstanceName, depth);
        return getRequestErrorResponseEntity(request);
    }

    @GetMapping(
            value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getSericeInstance(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType,
            @PathVariable(name = "service-instance-id") final String serviceInstanceId,
            @RequestParam(name = "depth", required = false) final Integer depth,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {

        LOGGER.info(
                "Will retrieve service instances for 'global customer id': {}, 'service type': {} and 'service instance id: '{} with depth: {}, resultIndex:{}, resultSize: {} and format: {}...",
                globalCustomerId, serviceType, serviceInstanceId, depth, resultIndex, resultSize, format);

        final Optional<ServiceInstance> optional =
                cacheServiceProvider.getServiceInstance(globalCustomerId, serviceType, serviceInstanceId);
        if (optional.isPresent()) {
            final ServiceInstance serviceInstance = optional.get();
            LOGGER.info("found service instance  {} in cache", serviceInstance);
            return ResponseEntity.ok(serviceInstance);
        }
        LOGGER.error(
                "Couldn't find 'global customer id': {}, 'service type': {} and 'service instance id': {} with depth: {}, resultIndex:{}, resultSize: {} and format: {} in cache",
                globalCustomerId, serviceType, serviceInstanceId, depth, resultIndex, resultSize, format);
        return getRequestErrorResponseEntity(request);
    }

    @PutMapping(
            value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putSericeInstance(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType,
            @PathVariable(name = "service-instance-id") final String serviceInstanceId,
            @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String invocationId,
            @RequestBody final ServiceInstance serviceInstance, final HttpServletRequest request) {

        LOGGER.info(
                "Will add service instance for 'global customer id': {}, 'service type': {} and 'service instance id: '{} ...",
                globalCustomerId, serviceType, serviceInstanceId);

        if (serviceInstance.getResourceVersion() == null || serviceInstance.getResourceVersion().isEmpty()) {
            serviceInstance.setResourceVersion(getResourceVersion());
        }

        if (cacheServiceProvider.putServiceInstance(globalCustomerId, serviceType, serviceInstanceId,
                serviceInstance)) {
            nodesCacheServiceProvider.putNodeServiceInstance(serviceInstanceId, new NodeServiceInstance(
                    globalCustomerId, serviceType, serviceInstanceId, SERVICE_RESOURCE_TYPE, request.getRequestURI()));
            return ResponseEntity.accepted().build();
        }

        LOGGER.error("Couldn't add 'global customer id': {}, 'service type': {} and 'service instance id': {} to cache",
                globalCustomerId, serviceType, serviceInstanceId);
        return getRequestErrorResponseEntity(request);
    }

    @PostMapping(
            value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> patchSericeInstance(@PathVariable("global-customer-id") final String globalCustomerId,
            @PathVariable("service-type") final String serviceType,
            @PathVariable(name = "service-instance-id") final String serviceInstanceId,
            @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
            @RequestBody final ServiceInstance serviceInstance, final HttpServletRequest request) {

        LOGGER.info(
                "Will post service instance for 'global customer id': {}, 'service type': {}, 'service instance id: '{} and '{}': {}...",
                globalCustomerId, serviceType, serviceInstanceId, X_HTTP_METHOD_OVERRIDE, xHttpHeaderOverride);

        if (HttpMethod.PATCH.toString().equalsIgnoreCase(xHttpHeaderOverride)) {
            cacheServiceProvider.patchServiceInstance(globalCustomerId, serviceType, serviceInstanceId,
                    serviceInstance);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("{} not supported ... ", xHttpHeaderOverride);

        return getRequestErrorResponseEntity(request);
    }


}
