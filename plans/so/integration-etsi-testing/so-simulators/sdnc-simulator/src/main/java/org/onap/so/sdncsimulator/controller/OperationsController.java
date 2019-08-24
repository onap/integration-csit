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

import static org.onap.so.sdncsimulator.utils.Constants.OPERATIONS_URL;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfOperationInformation;
import org.onap.so.sdncsimulator.models.InputRequest;
import org.onap.so.sdncsimulator.models.Output;
import org.onap.so.sdncsimulator.models.OutputRequest;
import org.onap.so.sdncsimulator.providers.ServiceOperationsCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = OPERATIONS_URL)
public class OperationsController {

    private static final Logger LOGGER = LoggerFactory.getLogger(OperationsController.class);

    private final ServiceOperationsCacheServiceProvider cacheServiceProvider;

    @Autowired
    public OperationsController(final ServiceOperationsCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PostMapping(value = "/GENERIC-RESOURCE-API:service-topology-operation/",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postServiceOperationInformation(
            @RequestBody final InputRequest<GenericResourceApiServiceOperationInformation> inputRequest,
            final HttpServletRequest request) {
        LOGGER.info("Request Received: {}  ...", inputRequest);

        final GenericResourceApiServiceOperationInformation apiServiceOperationInformation = inputRequest.getInput();

        if (apiServiceOperationInformation == null) {
            LOGGER.error("Invalid input request: {}", inputRequest);
            return ResponseEntity.badRequest().build();
        }

        final Output output = cacheServiceProvider.putServiceOperationInformation(apiServiceOperationInformation);
        final OutputRequest outputRequest = new OutputRequest(output);

        if (output.getResponseCode().equals(HttpStatus.OK.toString())) {
            LOGGER.info("Sucessfully added service in cache sending response: {}", outputRequest);
            return ResponseEntity.ok(outputRequest);
        }
        LOGGER.error("Unable to add input request: {}, will send OutputRequest: {}", inputRequest, outputRequest);
        return ResponseEntity.badRequest().body(outputRequest);

    }

    @PostMapping(value = "/GENERIC-RESOURCE-API:vnf-topology-operation/",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postVnfOperationInformation(
            @RequestBody final InputRequest<GenericResourceApiVnfOperationInformation> inputRequest,
            final HttpServletRequest request) {
        LOGGER.info("Request Received: {}  ...", inputRequest);

        final GenericResourceApiVnfOperationInformation apiVnfOperationInformation = inputRequest.getInput();
        if (apiVnfOperationInformation == null) {
            LOGGER.error("Invalid input request: {}", inputRequest);
            return ResponseEntity.badRequest().build();
        }

        final Output output = cacheServiceProvider.putVnfOperationInformation(apiVnfOperationInformation);
        final OutputRequest outputRequest = new OutputRequest(output);

        if (output.getResponseCode().equals(HttpStatus.OK.toString())) {
            LOGGER.info("Sucessfully added vnf in cache sending response: {}", outputRequest);
            return ResponseEntity.ok(outputRequest);
        }

        LOGGER.error("Unable to add input request: {}, will send OutputRequest: {}", inputRequest, outputRequest);
        return ResponseEntity.badRequest().body(outputRequest);

    }

}
