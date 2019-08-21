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
package org.onap.so.aaisimulator.controller;

import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNFS_URL;
import static org.onap.so.aaisimulator.utils.HttpServiceUtils.getHeaders;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.Relationship;
import org.onap.so.aaisimulator.service.providers.GenericVnfCacheServiceProvider;
import org.onap.so.aaisimulator.utils.HttpServiceUtils;
import org.onap.so.aaisimulator.utils.RequestErrorResponseUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = GENERIC_VNFS_URL)
public class GenericVnfsController {

    private static final Logger LOGGER = LoggerFactory.getLogger(GenericVnfsController.class);

    private final GenericVnfCacheServiceProvider cacheServiceProvider;


    @Autowired
    public GenericVnfsController(final GenericVnfCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "/generic-vnf/{vnf-id}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putGenericVnf(@RequestBody final GenericVnf genericVnf,
            @PathVariable("vnf-id") final String vnfId, final HttpServletRequest request) {
        LOGGER.info("Will add GenericVnf to cache with 'vnf-id': {} ...", vnfId);

        if (genericVnf.getResourceVersion() == null || genericVnf.getResourceVersion().isEmpty()) {
            genericVnf.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putGenericVnf(vnfId, genericVnf);
        return ResponseEntity.accepted().build();

    }

    @GetMapping(value = "/generic-vnf/{vnf-id}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getGenericVnf(@PathVariable("vnf-id") final String vnfId,
            @RequestParam(name = "depth", required = false) final Integer depth,
            @RequestParam(name = "resultIndex", required = false) final Integer resultIndex,
            @RequestParam(name = "resultSize", required = false) final Integer resultSize,
            @RequestParam(name = "format", required = false) final String format, final HttpServletRequest request) {
        LOGGER.info(
                "Will get GenericVnf for 'vnf-id': {} with depth: {}, resultIndex: {}, resultSize:{}, format:{} ...",
                vnfId, depth, resultIndex, resultSize, format);

        final Optional<GenericVnf> optional = cacheServiceProvider.getGenericVnf(vnfId);

        if (optional.isPresent()) {
            final GenericVnf genericVnf = optional.get();
            LOGGER.info("found GenericVnf {} in cache", genericVnf);
            return ResponseEntity.ok(genericVnf);
        }

        LOGGER.error(
                "Unable to find GenericVnf in cache for 'vnf-id': {} with depth: {}, resultIndex: {}, resultSize:{}, format:{} ...",
                vnfId, depth, resultIndex, resultSize, format);
        return getRequestErrorResponseEntity(request, GENERIC_VNF);

    }

    @PutMapping(value = "/generic-vnf/{vnf-id}/relationship-list/relationship",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putGenericVnfRelationShip(@RequestBody final Relationship relationship,
            @PathVariable("vnf-id") final String vnfId, final HttpServletRequest request) {
        LOGGER.info("Will put RelationShip for 'vnf-id': {} ...", vnfId);

        if (relationship.getRelatedLink() != null) {
            final String targetBaseUrl = HttpServiceUtils.getBaseUrl(request).toString();
            final HttpHeaders incomingHeader = getHeaders(request);
            boolean result = cacheServiceProvider.addRelationShip(incomingHeader, targetBaseUrl,
                    request.getRequestURI(), vnfId, relationship);
            if (result) {
                LOGGER.info("added created bi directional relationship with {}", relationship.getRelatedLink());
                return ResponseEntity.accepted().build();
            }
        }
        LOGGER.error("Unable to add relationship for related link: {}", relationship.getRelatedLink());
        return RequestErrorResponseUtils.getRequestErrorResponseEntity(request, GENERIC_VNF);
    }

}
