/*-
 * ============LICENSE_START=======================================================
 * Copyright 2021 Huawei Technologies Co., Ltd.
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
 * ============LICENSE_END=========================================================
 */
package org.onap.so.sdncsimulator.controller;

import static org.onap.so.sdncsimulator.utils.Constants.BASE_URL;
import java.util.Optional;
import javax.ws.rs.core.MediaType;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVnfTopology;
import org.onap.sdnc.northbound.client.model.GenericResourceApiVfModuleTopology;

import org.onap.so.sdncsimulator.providers.ServiceOperationsCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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
        final Optional<GenericResourceApiVnfTopology> optional =
                cacheServiceProvider.getGenericResourceApiVnfTopology(vnfId);
        if (optional.isPresent()) {
            final GenericResourceApiVnfTopology genericVnfTopology = optional.get();
            LOGGER.info("found VnfTopology {} in cache", genericVnfTopology);
            return ResponseEntity.ok(genericVnfTopology);
        }

        LOGGER.error(
                "Unable to find VnfTopology in cache ");

        return ResponseEntity.badRequest().build();
    }

    @GetMapping(value = "/config/GENERIC-RESOURCE-API:services/service/{service-id}/service-data/vnfs/vnf/{vnf-id}/vnf-data/vf-modules/vf-module/{vf-module-id}/vf-module-data/vf-module-topology/", produces = {
            MediaType.APPLICATION_JSON })
    public ResponseEntity<?> getVFmodule(@PathVariable("service-id") String serviceId,
                                         @PathVariable("vnf-id") String vnfId, @PathVariable("vf-module-id") String vfModuleId) {
        LOGGER.info("Get vfModule-topology with serviceId {}, vnfId {} and vfModuleId {}",serviceId, vnfId,vfModuleId);

        final Optional<GenericResourceApiVfModuleTopology> optional =
                cacheServiceProvider.getGenericResourceApiVfModuleTopology(vfModuleId);

        if (optional.isPresent()) {
            final GenericResourceApiVfModuleTopology vfModuleTopology = optional.get();
            LOGGER.info("found vfModuleTopology {} in cache", vfModuleTopology);
            return ResponseEntity.ok(vfModuleTopology);
        }

        LOGGER.error(
                "Unable to find VfModuleTopology in cache for ");

        return ResponseEntity.badRequest().build();
    }
}
