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

import static org.onap.sdnc.northbound.client.model.GenericResourceApiRequestActionEnumeration.DELETESERVICEINSTANCE;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiRequestActionEnumeration.DELETEVNFINSTANCE;
import static org.onap.sdnc.northbound.client.model.GenericResourceApiSvcActionEnumeration.DELETE;
import static org.onap.so.sdncsimulator.utils.Constants.OPERATIONS_URL;
import static org.onap.so.sdncsimulator.utils.Constants.BASE_URL;
import static org.onap.so.sdncsimulator.utils.Constants.RESTCONF_CONFIG_END_POINT;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;

import org.onap.sdnc.northbound.client.model.*;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;


/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = BASE_URL)
public class OperationsController {
    private static final String HTTP_STATUS_OK = HttpStatus.OK.value() + "";

    private static final Logger LOGGER = LoggerFactory.getLogger(OperationsController.class);

    private final ServiceOperationsCacheServiceProvider cacheServiceProvider;

    @Autowired
    public OperationsController(final ServiceOperationsCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PostMapping(value = "/operations/GENERIC-RESOURCE-API:service-topology-operation/",
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

        final Output output = getOutput(apiServiceOperationInformation);
        final OutputRequest outputRequest = new OutputRequest(output);

        if (output.getResponseCode().equals(HTTP_STATUS_OK)) {
            LOGGER.info("Sucessfully executed service request sending response: {}", outputRequest);
            return ResponseEntity.ok(outputRequest);
        }
        LOGGER.error("Unable to execute input request: {}, will send OutputRequest: {}", inputRequest, outputRequest);
        return ResponseEntity.badRequest().body(outputRequest);

    }

    @PostMapping(value = "/operations/GENERIC-RESOURCE-API:vnf-topology-operation/",
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

        final Output output = getOutput(apiVnfOperationInformation);
        final OutputRequest outputRequest = new OutputRequest(output);

        if (output.getResponseCode().equals(HTTP_STATUS_OK)) {
            LOGGER.info("Sucessfully executed request vnf sending response: {}", outputRequest);
            return ResponseEntity.ok(outputRequest);
        }

        LOGGER.error("Unable to execute input request: {}, will send OutputRequest: {}", inputRequest, outputRequest);
        return ResponseEntity.badRequest().body(outputRequest);

    }

    private Output getOutput(final GenericResourceApiServiceOperationInformation serviceOperationInformation) {
        final GenericResourceApiRequestinformationRequestInformation requestInformation =
                serviceOperationInformation.getRequestInformation();
        final GenericResourceApiSdncrequestheaderSdncRequestHeader sdncRequestHeader =
                serviceOperationInformation.getSdncRequestHeader();
        if (requestInformation != null && sdncRequestHeader != null) {
            final GenericResourceApiRequestActionEnumeration requestAction = requestInformation.getRequestAction();
            final GenericResourceApiSvcActionEnumeration svcAction = sdncRequestHeader.getSvcAction();
            if (DELETESERVICEINSTANCE.equals(requestAction) && DELETE.equals(svcAction)) {
                LOGGER.info("RequestAction: {} and SvcAction: {} will delete service instance from cache ...",
                        requestAction, svcAction);
                return cacheServiceProvider.deleteServiceOperationInformation(serviceOperationInformation);
            }
        }
        return cacheServiceProvider.putServiceOperationInformation(serviceOperationInformation);
    }

    private Output getOutput(final GenericResourceApiVnfOperationInformation apiVnfOperationInformation) {
        final GenericResourceApiRequestinformationRequestInformation requestInformation =
                apiVnfOperationInformation.getRequestInformation();
        if (requestInformation != null) {
            final GenericResourceApiRequestActionEnumeration requestAction = requestInformation.getRequestAction();
            if (DELETEVNFINSTANCE.equals(requestAction)) {
                LOGGER.info("RequestAction: {} will delete vnf instance from cache ...", requestAction);
                return cacheServiceProvider.deleteVnfOperationInformation(apiVnfOperationInformation);
            }
        }
        return cacheServiceProvider.putVnfOperationInformation(apiVnfOperationInformation);
    }

    @PostMapping(value = "/operations/GENERIC-RESOURCE-API:vf-module-topology-operation/",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> postVfModuleOperationInformation(
            @RequestBody final InputRequest<GenericResourceApiVfModuleOperationInformation> inputRequest,
            final HttpServletRequest request) {
        LOGGER.info("Request Received for VfModule : {}  ...", inputRequest);

        final GenericResourceApiVfModuleOperationInformation apiVfModuleperationInformation = inputRequest.getInput();
        if (apiVfModuleperationInformation == null) {
            LOGGER.error("Invalid input request: {}", inputRequest);
            return ResponseEntity.badRequest().build();
        }

        final Output output = getOutput(apiVfModuleperationInformation);
        final OutputRequest outputRequest = new OutputRequest(output);

        if (output.getResponseCode().equals(HTTP_STATUS_OK)) {
            LOGGER.info("Sucessfully executed request vnf sending response: {}", outputRequest);
            return ResponseEntity.ok(outputRequest);
        }

        LOGGER.error("Unable to execute input request: {}, will send OutputRequest: {}", inputRequest, outputRequest);
        return ResponseEntity.badRequest().body(outputRequest);

    }

    private Output getOutput(final GenericResourceApiVfModuleOperationInformation apiVfModuleOperationInformation) {
        final GenericResourceApiRequestinformationRequestInformation requestInformation =
                apiVfModuleOperationInformation.getRequestInformation();

        return cacheServiceProvider.putVfModuleOperationInformation(apiVfModuleOperationInformation);
    }

    
    @GetMapping(value = "/config/GENERIC-RESOURCE-API:services/service/{service-id}/service-data/vnfs/vnf/{vnf-id}/vnf-data/vnf-topology/")
	public ResponseEntity<?> getVNf(@PathVariable("service-id") String serviceId,
			@PathVariable("vnf-id") String vnfId) {

    	LOGGER.info("Get call for vnf-topology");
		GenericResourceApiVnfTopology genericResourceApiVnfTopology = new GenericResourceApiVnfTopology();
		
		genericResourceApiVnfTopology = cacheServiceProvider.getGenericResourceApiVnfTopology();
		return ResponseEntity.ok(genericResourceApiVnfTopology);
	}

	@GetMapping(value = "/config/GENERIC-RESOURCE-API:services/service/{service-id}/service-data/vnfs/vnf/{vnf-id}/vnf-data/vf-modules/vf-module/{vf-module-id}/vf-module-data/vf-module-topology/", produces = {
			MediaType.APPLICATION_JSON })
	public ResponseEntity<?> getVFmodule(@PathVariable("service-id") String serviceId,
			@PathVariable("vnf-id") String vnfId, @PathVariable("vf-module-id") String vfModuleId) {
		LOGGER.info("Get call for vfModule-topology");

		GenericResourceApiVfModuleTopology genericResourceApiVfModuleTopology = new GenericResourceApiVfModuleTopology();

		genericResourceApiVfModuleTopology = cacheServiceProvider.getGenericResourceApiVfModuleTopology();
		return ResponseEntity.ok(genericResourceApiVfModuleTopology);

	}
}
