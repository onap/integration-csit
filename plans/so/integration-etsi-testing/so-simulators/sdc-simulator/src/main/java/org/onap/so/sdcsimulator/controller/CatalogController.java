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
import org.onap.so.sdcsimulator.models.AssetType;
import org.onap.so.sdcsimulator.models.Metadata;
import org.onap.so.sdcsimulator.providers.AssetProvider;
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

    private final AssetProvider assetProvider;

    @Autowired
    public CatalogController(final AssetProvider assetProvider) {
        this.assetProvider = assetProvider;
    }

    @GetMapping(value = "/resources", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getResources() {
        LOGGER.info("Running getResources ...");
        return ResponseEntity.ok().body(assetProvider.getAssetInfo(AssetType.RESOURCES));
    }

    @GetMapping(value = "/resources/{csarId}/toscaModel", produces = MediaType.APPLICATION_OCTET_STREAM)
    public ResponseEntity<byte[]> getResourceCsar(@PathVariable("csarId") final String csarId) {
        LOGGER.info("Running getCsar for {} ...", csarId);
        final Optional<byte[]> resource = assetProvider.getAsset(csarId, AssetType.RESOURCES);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find csar: {}", csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @GetMapping(value = "/resources/{csarId}/metadata",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<Metadata> getResourceMetadata(@PathVariable("csarId") final String csarId) {
        LOGGER.info("Running getResourceMetadata for {} ...", csarId);
        final Optional<Metadata> resource = assetProvider.getMetadata(csarId, AssetType.RESOURCES);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find metadata for csarId: {}", csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }


    @GetMapping(value = "/services", produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getServices() {
        LOGGER.info("Running getServices ...");
        return ResponseEntity.ok().body(assetProvider.getAssetInfo(AssetType.SERVICES));
    }

    @GetMapping(value = "/services/{csarId}/toscaModel", produces = MediaType.APPLICATION_OCTET_STREAM)
    public ResponseEntity<byte[]> getServiceCsar(@PathVariable("csarId") final String csarId) {
        LOGGER.info("Running getServiceCsar for {} ...", csarId);
        final Optional<byte[]> resource = assetProvider.getAsset(csarId, AssetType.SERVICES);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find csar: {}", csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }


    @GetMapping(value = "/services/{csarId}/metadata",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<Metadata> getServiceMetadata(@PathVariable("csarId") final String csarId) {
        LOGGER.info("Running getServiceMetadata for {} ...", csarId);
        final Optional<Metadata> resource = assetProvider.getMetadata(csarId, AssetType.SERVICES);
        if (resource.isPresent()) {
            return new ResponseEntity<>(resource.get(), HttpStatus.OK);
        }
        LOGGER.error("Unable to find metadata for csarId: {}", csarId);

        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }


}
