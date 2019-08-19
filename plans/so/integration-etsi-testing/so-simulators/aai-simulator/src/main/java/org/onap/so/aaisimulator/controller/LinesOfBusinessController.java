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

import static org.onap.so.aaisimulator.utils.Constants.LINES_OF_BUSINESS_URL;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.LineOfBusiness;
import org.onap.so.aaisimulator.service.providers.LinesOfBusinessCacheServiceProvider;
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
@RequestMapping(path = LINES_OF_BUSINESS_URL)
public class LinesOfBusinessController {
    private static final Logger LOGGER = LoggerFactory.getLogger(LinesOfBusinessController.class);

    private final LinesOfBusinessCacheServiceProvider cacheServiceProvider;

    @Autowired
    public LinesOfBusinessController(final LinesOfBusinessCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{line-of-business-name}", consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putLineOfBusiness(@RequestBody final LineOfBusiness lineOfBusiness,
            @PathVariable("line-of-business-name") final String lineOfBusinessName, final HttpServletRequest request) {

        LOGGER.info("Will add LineOfBusiness to cache with key 'line-of-business-name': {} ...",
                lineOfBusiness.getLineOfBusinessName());

        if (lineOfBusiness.getResourceVersion() == null || lineOfBusiness.getResourceVersion().isEmpty()) {
            lineOfBusiness.setResourceVersion(getResourceVersion());

        }
        cacheServiceProvider.putLineOfBusiness(lineOfBusinessName, lineOfBusiness);
        return ResponseEntity.accepted().build();
    }


    @GetMapping(value = "/{line-of-business-name}", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getLineOfBusiness(@PathVariable("line-of-business-name") final String lineOfBusinessName,
            final HttpServletRequest request) {
        LOGGER.info("retrieving Platform for 'platform-name': {} ...", lineOfBusinessName);
        final Optional<LineOfBusiness> optional = cacheServiceProvider.getLineOfBusiness(lineOfBusinessName);
        if (optional.isPresent()) {
            final LineOfBusiness platform = optional.get();
            LOGGER.info("found LineOfBusiness {} in cache", platform);
            return ResponseEntity.ok(platform);
        }
        LOGGER.error("Unable to find LineOfBusiness in cahce using {}", lineOfBusinessName);
        return getRequestErrorResponseEntity(request);
    }

}
