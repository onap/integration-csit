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
package org.onap.aaisimulator.controller;

import static org.onap.aaisimulator.utils.Constants.CUSTOMER_URL;
import static org.onap.aaisimulator.utils.Constants.SERVICE_RESOURCE_TYPE;
import static org.onap.aaisimulator.utils.Constants.X_HTTP_METHOD_OVERRIDE;
import static org.onap.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;

import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.service.providers.ServiceInstanceCacheProvider;
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

@Controller
@RequestMapping(path = CUSTOMER_URL)
public class BusinessController {

    private static final Logger LOGGER = LoggerFactory.getLogger(BusinessController.class);

    private final ServiceInstanceCacheProvider svcInstanceCacheSvcProvider;

    @Autowired
    public BusinessController(final ServiceInstanceCacheProvider serviceInstanceCacheProvider) {
        this.svcInstanceCacheSvcProvider = serviceInstanceCacheProvider;
    }

    @PutMapping(value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
        produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putServiceInstance(@PathVariable("global-customer-id") final String globalCustomerId,
        @PathVariable("service-type") final String serviceType,
        @PathVariable(name = "service-instance-id") final String serviceInstanceId,
        @RequestBody final ServiceInstance serviceInstance, final HttpServletRequest request) {

        LOGGER.info("Add service instance to cache for 'global customer id': {}, 'service type': {} and "
            + "'service instance id: '{}..", globalCustomerId, serviceType, serviceInstanceId);

        if (svcInstanceCacheSvcProvider.putServiceInstance(globalCustomerId, serviceInstance)) {
            LOGGER.info("Successfully added service instance to cache ...");
            return ResponseEntity.accepted().build();
        }

        LOGGER.error(
            "Couldn't add service instance for 'global customer id': {},'service type': {} and 'service instance id: '{} ...",
            globalCustomerId, serviceType, serviceInstanceId);
        return getRequestErrorResponseEntity(request, SERVICE_RESOURCE_TYPE);
    }

    @GetMapping(value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
        produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getServiceInstance(@PathVariable("global-customer-id") final String globalCustomerId,
        @PathVariable("service-type") final String serviceType,
        @PathVariable(name = "service-instance-id") final String serviceInstanceId,
        @RequestParam(name = "depth", required = false) final Integer depth,
        @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
        @RequestParam(name = "resultSize", required = false) final Integer resultSize,
        @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {

        LOGGER.info(
            "Retrieve service instances for 'global customer id': {}, 'service type': {} and 'service instance id: '{} with depth: {}, resultIndex:{}, resultSize: {} and format: {}...",
            globalCustomerId, serviceType, serviceInstanceId, depth, resultIndex, resultSize, format);

        final Optional<ServiceInstance> svcInstance =
            svcInstanceCacheSvcProvider.getServiceInstance(globalCustomerId);

        if (svcInstance.isPresent()) {
            final ServiceInstance serviceInstance = svcInstance.get();
            LOGGER.info("Found service instance  {} in cache", serviceInstance);
            return ResponseEntity.ok(serviceInstance);
        }

        LOGGER.error(
            "Couldn't find 'global customer id': {}, 'service type': {} and 'service instance id': {} with depth: {}, resultIndex:{}, resultSize: {} and format: {} in cache",
            globalCustomerId, serviceType, serviceInstanceId, depth, resultIndex, resultSize, format);
        return getRequestErrorResponseEntity(request);
    }

    @PostMapping(value = "/{global-customer-id}/service-subscriptions/service-subscription/{service-type}/service-instances/service-instance/{service-instance-id}",
        produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> patchServiceInstance(@PathVariable("global-customer-id") final String globalCustomerId,
        @PathVariable("service-type") final String serviceType,
        @PathVariable(name = "service-instance-id") final String serviceInstanceId,
        @RequestHeader(value = X_HTTP_METHOD_OVERRIDE, required = false) final String xHttpHeaderOverride,
        @RequestBody final ServiceInstance serviceInstance, final HttpServletRequest request) {

        LOGGER.info(
            "Post service instance for 'global customer id': {}, 'service type': {}, 'service instance id: '{} and '{}': {}...",
            globalCustomerId, serviceType, serviceInstanceId, X_HTTP_METHOD_OVERRIDE, xHttpHeaderOverride);

        if (HttpMethod.PATCH.toString().equalsIgnoreCase(xHttpHeaderOverride)) {
            svcInstanceCacheSvcProvider.patchServiceInstance(globalCustomerId, serviceInstance);
            return ResponseEntity.accepted().build();
        }
        LOGGER.error("{} not supported ... ", xHttpHeaderOverride);

        return getRequestErrorResponseEntity(request);
    }
}