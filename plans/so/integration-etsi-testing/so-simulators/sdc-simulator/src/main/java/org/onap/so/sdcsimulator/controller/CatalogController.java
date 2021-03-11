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
package org.onap.so.sdcsimulator.controller;

import static org.onap.so.sdcsimulator.utils.Constants.CATALOG_URL;
import java.util.Optional;
import javax.ws.rs.core.MediaType;
import org.onap.so.sdcsimulator.providers.ResourceProvider;
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
@RequestMapping(path = CATALOG_URL)
public class CatalogController {
    private static final Logger LOGGER = LoggerFactory.getLogger(CatalogController.class);

    private ResourceProvider resourceProvider;

    @Autowired
    public CatalogController(final ResourceProvider resourceProvider) {
        this.resourceProvider = resourceProvider;
    }

    @GetMapping(value = "/resources", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getResources() {
        LOGGER.info("Running getResources ...");
        return ResponseEntity.ok().body(resourceProvider.getResource());
    }

    @GetMapping(value = "/resources/{csarId}/toscaModel", produces = MediaType.APPLICATION_OCTET_STREAM)
    public ResponseEntity<byte[]> getCsar(@PathVariable("csarId") final String csarId) {
        LOGGER.info("Running getCsar for {} ...", csarId);
        final Optional<byte[]> resource = resourceProvider.getResource(csarId);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find csar: {}", csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

}
