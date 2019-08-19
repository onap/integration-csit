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

import static org.onap.so.aaisimulator.utils.Constants.PLATFORMS_URL;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.Platform;
import org.onap.aai.domain.yang.Relationship;
import org.onap.so.aaisimulator.service.providers.PlatformCacheServiceProvider;
import org.onap.so.aaisimulator.utils.RequestErrorResponseUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = PLATFORMS_URL)
public class PlatformController {
    private static final Logger LOGGER = LoggerFactory.getLogger(PlatformController.class);

    private final PlatformCacheServiceProvider cacheServiceProvider;

    @Autowired
    public PlatformController(final PlatformCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{platform-name}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putPlatform(@RequestBody final Platform platform,
            @PathVariable("platform-name") final String platformName, final HttpServletRequest request) {
        LOGGER.info("Will add Platform to cache with key 'platform-name': {} ...", platform.getPlatformName());

        if (platform.getResourceVersion() == null || platform.getResourceVersion().isEmpty()) {
            platform.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putPlatform(platformName, platform);
        return ResponseEntity.accepted().build();
    }

    @GetMapping(value = "/{platform-name}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getPlatform(@PathVariable("platform-name") final String platformName,
            final HttpServletRequest request) {
        LOGGER.info("retrieving Platform for 'platform-name': {} ...", platformName);
        final Optional<Platform> optional = cacheServiceProvider.getPlatform(platformName);
        if (optional.isPresent()) {
            final Platform platform = optional.get();
            LOGGER.info("found Platform {} in cache", platform);
            return ResponseEntity.ok(platform);
        }
        LOGGER.error("Unable to find Platform in cahce using {}", platformName);
        return getRequestErrorResponseEntity(request);
    }

    @PutMapping(value = "/{platform-name}/relationship-list/relationship",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putSericeInstanceRelationShip(@PathVariable("platform-name") final String platformName,
            @RequestBody final Relationship relationship, final HttpServletRequest request) {
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(platformName, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Couldn't add {} relationship for 'platform-name': {} ...", relationship.getRelatedTo(),
                platformName);

        return RequestErrorResponseUtils.getRequestErrorResponseEntity(request);

    }
}
