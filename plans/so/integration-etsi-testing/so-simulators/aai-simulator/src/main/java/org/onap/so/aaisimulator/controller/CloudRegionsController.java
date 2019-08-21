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

import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGION;
import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGIONS;
import static org.onap.so.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getRequestErrorResponseEntity;
import static org.onap.so.aaisimulator.utils.RequestErrorResponseUtils.getResourceVersion;
import java.util.Optional;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.MediaType;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.Tenant;
import org.onap.so.aaisimulator.models.CloudRegionKey;
import org.onap.so.aaisimulator.service.providers.CloudRegionCacheServiceProvider;
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
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Controller
@RequestMapping(path = CLOUD_REGIONS)
public class CloudRegionsController {
    private static final Logger LOGGER = LoggerFactory.getLogger(CloudRegionsController.class);

    private final CloudRegionCacheServiceProvider cacheServiceProvider;

    @Autowired
    public CloudRegionsController(final CloudRegionCacheServiceProvider cacheServiceProvider) {
        this.cacheServiceProvider = cacheServiceProvider;
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putCloudRegion(@RequestBody final CloudRegion cloudRegion,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        if (key.isValid()) {
            LOGGER.info("Will add CloudRegion to cache with key 'key': {} ....", key);
            if (cloudRegion.getResourceVersion() == null || cloudRegion.getResourceVersion().isEmpty()) {
                cloudRegion.setResourceVersion(getResourceVersion());
            }
            cacheServiceProvider.putCloudRegion(key, cloudRegion);
            return ResponseEntity.accepted().build();
        }

        LOGGER.error("Unable to add CloudRegion in cache because of invalid key {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getCloudRegion(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @RequestParam(name = "depth", required = false) final Integer depth, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving CloudRegion using key : {} with depth: {}...", key, depth);
        if (key.isValid()) {
            final Optional<CloudRegion> optional = cacheServiceProvider.getCloudRegion(key);
            if (optional.isPresent()) {
                final CloudRegion cloudRegion = optional.get();
                LOGGER.info("found CloudRegion {} in cache", cloudRegion);
                return ResponseEntity.ok(cloudRegion);
            }
        }
        LOGGER.error("Unable to find CloudRegion in cache using {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}" + BI_DIRECTIONAL_RELATIONSHIP_LIST_URL,
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putRelationShip(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId, @RequestBody final Relationship relationship,
            final HttpServletRequest request) {
        LOGGER.info("Will add {} relationship to : {} ...", relationship.getRelatedTo());

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        final Optional<Relationship> optional =
                cacheServiceProvider.addRelationShip(key, relationship, request.getRequestURI());

        if (optional.isPresent()) {
            final Relationship resultantRelationship = optional.get();
            LOGGER.info("Relationship add, sending resultant relationship: {} in response ...", resultantRelationship);
            return ResponseEntity.accepted().body(resultantRelationship);
        }

        LOGGER.error("Couldn't add {} relationship for 'key': {} ...", relationship.getRelatedTo(), key);

        return getRequestErrorResponseEntity(request, CLOUD_REGION);

    }

    @PutMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}",
            consumes = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML},
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> putTenant(@RequestBody final Tenant tenant,
            @PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, final HttpServletRequest request) {

        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);

        if (key.isValid()) {
            LOGGER.info("Will add Tenant to cache with key 'key': {} ....", key);
            if (tenant.getResourceVersion() == null || tenant.getResourceVersion().isEmpty()) {
                tenant.setResourceVersion(getResourceVersion());
            }
            if (cacheServiceProvider.putTenant(key, tenant)) {
                return ResponseEntity.accepted().build();
            }
        }

        LOGGER.error("Unable to add Tenant in cache using key {}", key);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }

    @GetMapping(value = "{cloud-owner}/{cloud-region-id}/tenants/tenant/{tenant-id}",
            produces = {MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public ResponseEntity<?> getTenant(@PathVariable("cloud-owner") final String cloudOwner,
            @PathVariable("cloud-region-id") final String cloudRegionId,
            @PathVariable("tenant-id") final String tenantId, final HttpServletRequest request) {
        final CloudRegionKey key = new CloudRegionKey(cloudOwner, cloudRegionId);
        LOGGER.info("Retrieving Tenant using key : {} and tenant-id:{} ...", key, tenantId);
        if (key.isValid()) {
            final Optional<Tenant> optional = cacheServiceProvider.getTenant(key, tenantId);
            if (optional.isPresent()) {
                final Tenant tenant = optional.get();
                LOGGER.info("found Tenant {} in cache", tenant);
                return ResponseEntity.ok(tenant);
            }
        }
        LOGGER.error("Unable to find Tenant in cache key : {} and tenant-id:{} ...", key, tenantId);
        return getRequestErrorResponseEntity(request, CLOUD_REGION);
    }
}
