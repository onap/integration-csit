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

import org.onap.sdnc.northbound.client.model.GenericResourceApiRequestActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiRequestinformationRequestInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiSdncrequestheaderSdncRequestHeader;
import org.onap.sdnc.northbound.client.model.GenericResourceApiServiceOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiSvcActionEnumeration;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVfModuleOperationInformation;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfTopology;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVfModuleTopology;
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
public class ConfigController {
    private static final String HTTP_STATUS_OK = HttpStatus.OK.value() + "";

    private static final Logger LOGGER = LoggerFactory.getLogger(OperationsController.class);

    private final ServiceOperationsCacheServiceProvider cacheServiceProvider;

    @Autowired
    public ConfigController(final ServiceOperationsCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @GetMapping(value = "/config/GENERIC-RESOURCE-API:services/service/{service-id}/service-data/vnfs/vnf/{vnf-id}/vnf-data/vnf-topology/")
    public ResponseEntity<?> getVNf(@PathVariable("service-id") String serviceId,
                                    @PathVariable("vnf-id") String vnfId) {

        LOGGER.info("Get vnf-topology with serviceId {} and vnfId {}",serviceId, vnfId);
        GenericResourceApiVnfTopology genericResourceApiVnfTopology = new GenericResourceApiVnfTopology();

        genericResourceApiVnfTopology = cacheServiceProvider.getGenericResourceApiVnfTopology();
        return ResponseEntity.ok(genericResourceApiVnfTopology);
    }

    @GetMapping(value = "/config/GENERIC-RESOURCE-API:services/service/{service-id}/service-data/vnfs/vnf/{vnf-id}/vnf-data/vf-modules/vf-module/{vf-module-id}/vf-module-data/vf-module-topology/", produces = {
            MediaType.APPLICATION_JSON })
    public ResponseEntity<?> getVFmodule(@PathVariable("service-id") String serviceId,
                                         @PathVariable("vnf-id") String vnfId, @PathVariable("vf-module-id") String vfModuleId) {
        LOGGER.info("Get vfModule-topology with serviceId {}, vnfId {} and vfModuleId {}",serviceId, vnfId,vfModuleId);

        GenericResourceApiVfModuleTopology genericResourceApiVfModuleTopology = new GenericResourceApiVfModuleTopology();

        genericResourceApiVfModuleTopology = cacheServiceProvider.getGenericResourceApiVfModuleTopology();
        return ResponseEntity.ok(genericResourceApiVfModuleTopology);

    }
}
