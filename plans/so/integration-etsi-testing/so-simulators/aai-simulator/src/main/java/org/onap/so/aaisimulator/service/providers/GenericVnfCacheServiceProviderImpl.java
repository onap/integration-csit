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
package org.onap.so.aaisimulator.service.providers;

import static org.onap.so.aaisimulator.utils.CacheName.GENERIC_VNF_CACHE;
import static org.onap.so.aaisimulator.utils.Constants.COMPOSED_OF;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF_VNF_ID;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF_VNF_NAME;
import static org.onap.so.aaisimulator.utils.Constants.USES;
import static org.onap.so.aaisimulator.utils.Constants.VF_MODULE;
import static org.onap.so.aaisimulator.utils.Constants.VF_MODULE_VF_MODULE_ID;
import static org.onap.so.aaisimulator.utils.HttpServiceUtils.getBiDirectionalRelationShipListRelatedLink;
import static org.onap.so.aaisimulator.utils.HttpServiceUtils.getRelationShipListRelatedLink;
import static org.onap.so.aaisimulator.utils.HttpServiceUtils.getTargetUrl;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.aai.domain.yang.VfModule;
import org.onap.aai.domain.yang.VfModules;
import org.onap.so.aaisimulator.utils.ShallowBeanCopy;
import org.onap.so.simulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class GenericVnfCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements GenericVnfCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(GenericVnfCacheServiceProviderImpl.class);

    private final HttpRestServiceProvider httpRestServiceProvider;

    @Autowired
    public GenericVnfCacheServiceProviderImpl(final CacheManager cacheManager,
            final HttpRestServiceProvider httpRestServiceProvider) {
        super(cacheManager);
        this.httpRestServiceProvider = httpRestServiceProvider;
    }

    @Override
    public void putGenericVnf(final String vnfId, final GenericVnf genericVnf) {
        LOGGER.info("Adding customer: {} with key: {} in cache ...", genericVnf, vnfId);
        final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
        cache.put(vnfId, genericVnf);
    }

    @Override
    public Optional<GenericVnf> getGenericVnf(final String vnfId) {
        LOGGER.info("getting GenericVnf from cache using key: {}", vnfId);
        final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
        final GenericVnf value = cache.get(vnfId, GenericVnf.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find GenericVnf ...");
        return Optional.empty();
    }

    @Override
    public Optional<String> getGenericVnfId(final String vnfName) {
        final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
        if (cache != null) {
            final Object nativeCache = cache.getNativeCache();
            if (nativeCache instanceof ConcurrentHashMap) {
                @SuppressWarnings("unchecked")
                final ConcurrentHashMap<Object, Object> concurrentHashMap =
                        (ConcurrentHashMap<Object, Object>) nativeCache;
                for (final Object key : concurrentHashMap.keySet()) {
                    final Optional<GenericVnf> optional = getGenericVnf(key.toString());
                    if (optional.isPresent()) {
                        final GenericVnf value = optional.get();
                        final String genericVnfName = value.getVnfName();
                        if (genericVnfName != null && genericVnfName.equals(vnfName)) {
                            final String genericVnfId = value.getVnfId();
                            LOGGER.info("Found matching vnf for name: {}, vnf-id: {}", genericVnfName, genericVnfId);
                            return Optional.of(genericVnfId);
                        }
                    }
                }
            }
        }
        LOGGER.error("No match found for vnf name: {}", vnfName);
        return Optional.empty();
    }

    @Override
    public boolean addRelationShip(final HttpHeaders incomingHeader, final String targetBaseUrl,
            final String requestUriString, final String vnfId, final Relationship relationship) {
        try {
            final Optional<GenericVnf> optional = getGenericVnf(vnfId);
            if (optional.isPresent()) {
                final GenericVnf genericVnf = optional.get();
                final String targetUrl = getTargetUrl(targetBaseUrl, relationship.getRelatedLink());
                final Relationship outGoingRelationShip =
                        getRelationship(getRelationShipListRelatedLink(requestUriString), genericVnf, COMPOSED_OF);
                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);
                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();

                    RelationshipList relationshipList = genericVnf.getRelationshipList();
                    if (relationshipList == null) {
                        relationshipList = new RelationshipList();
                        genericVnf.setRelationshipList(relationshipList);
                    }
                    if (relationshipList.getRelationship().add(resultantRelationship)) {
                        LOGGER.info("added relationship {} in cache successfully", resultantRelationship);
                        return true;
                    }
                }
            }
        } catch (final Exception exception) {
            LOGGER.error("Unable to add two-way relationship for vnfId: {}", vnfId, exception);
        }
        LOGGER.error("Unable to add relationship in cache for vnfId: {}", vnfId);
        return false;
    }

    @Override
    public Optional<Relationship> addRelationShip(final String vnfId, final Relationship relationship,
            final String requestURI) {
        final Optional<GenericVnf> optional = getGenericVnf(vnfId);
        if (optional.isPresent()) {
            final GenericVnf genericVnf = optional.get();
            RelationshipList relationshipList = genericVnf.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                genericVnf.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);
            LOGGER.info("Successfully added relation to GenericVnf for vnfId: {}", vnfId);

            final String relatedLink = getBiDirectionalRelationShipListRelatedLink(requestURI);
            final Relationship resultantRelationship =
                    getRelationship(relatedLink, genericVnf, relationship.getRelationshipLabel());
            return Optional.of(resultantRelationship);
        }
        return Optional.empty();
    }

    @Override
    public boolean patchGenericVnf(final String vnfId, final GenericVnf genericVnf) {
        final Optional<GenericVnf> optional = getGenericVnf(vnfId);
        if (optional.isPresent()) {
            final GenericVnf cachedGenericVnf = optional.get();
            try {
                ShallowBeanCopy.copy(genericVnf, cachedGenericVnf);
                return true;
            } catch (final Exception exception) {
                LOGGER.error("Unable to update GenericVnf for vnfId: {}", vnfId, exception);
            }
        }
        LOGGER.error("Unable to find GenericVnf ...");
        return false;
    }

    @Override
    public List<GenericVnf> getGenericVnfs() {
        final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
        if (cache != null) {
            final Object nativeCache = cache.getNativeCache();
            if (nativeCache instanceof ConcurrentHashMap) {
                @SuppressWarnings("unchecked")
                final ConcurrentHashMap<Object, Object> concurrentHashMap =
                    (ConcurrentHashMap<Object, Object>) nativeCache;
                final List<GenericVnf> result = new ArrayList<>();

                concurrentHashMap.keySet().forEach(key -> {
                    final Optional<GenericVnf> optional = getGenericVnf(key.toString());
                    if (optional.isPresent()) {
                        final GenericVnf genericVnf = optional.get();
                        result.add(genericVnf);
                    }
                });
                return result;
            }
        }
        LOGGER.error("No match found");
        return Collections.emptyList();
    }

    @Override
    public boolean deleteGenericVnf(final String vnfId, final String resourceVersion) {
        final Optional<GenericVnf> optional = getGenericVnf(vnfId);
        if (optional.isPresent()) {
            final GenericVnf genericVnf = optional.get();
            if (genericVnf.getResourceVersion() != null && genericVnf.getResourceVersion().equals(resourceVersion)) {
                final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
                LOGGER.info("Will evict GenericVnf from cache with vnfId: {}", genericVnf.getVnfId());
                cache.evict(vnfId);
                return true;
            }
        }
        LOGGER.error("Unable to find GenericVnf for vnfId: {} and resourceVersion: {} ...", vnfId, resourceVersion);
        return false;
    }

    private Relationship getRelationship(final String relatedLink, final GenericVnf genericVnf,
            final String relationshipLabel) {
        final Relationship relationShip = new Relationship();
        relationShip.setRelatedTo(GENERIC_VNF);
        relationShip.setRelationshipLabel(relationshipLabel);
        relationShip.setRelatedLink(relatedLink);

        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(GENERIC_VNF_VNF_ID);
        relationshipData.setRelationshipValue(genericVnf.getVnfId());
        relationShip.getRelationshipData().add(relationshipData);

        final RelatedToProperty relatedToProperty = new RelatedToProperty();
        relatedToProperty.setPropertyKey(GENERIC_VNF_VNF_NAME);
        relatedToProperty.setPropertyValue(genericVnf.getVnfName());
        relationShip.getRelatedToProperty().add(relatedToProperty);
        return relationShip;
    }

    @Override
    public void clearAll() {
        clearCache(GENERIC_VNF_CACHE.getName());
    }

    @Override
    public Optional<VfModule> getVfModule(final String vnfId, final String vfModuleId) {
        LOGGER.info("Getting vfModule from cache for vnfId: {} and vfModuleId: {}", vnfId, vfModuleId);
        final Optional<GenericVnf> genericVnfOptional = getGenericVnf(vnfId);
        final GenericVnf value = genericVnfOptional.get();
        final VfModules vfmodules = value.getVfModules();
        if (vfmodules != null) {
            for (final VfModule vfModule : vfmodules.getVfModule()) {
                if (vfModule.getVfModuleId().equalsIgnoreCase(vfModuleId)) {
                    return Optional.of(vfModule);
                }
            }
        }
        return Optional.empty();
    }


    @Override
    public void putVfModule(final String vnfId, final String vfModuleId, final VfModule vfModule) {
        LOGGER.info("Adding vfModule for vnfId: {} and vfModuleId: {}", vnfId, vfModuleId);
        final Optional<GenericVnf> genericVnfOptional = getGenericVnf(vnfId);
        final Cache cache = getCache(GENERIC_VNF_CACHE.getName());
        if (genericVnfOptional.isPresent()) {
            final GenericVnf genericVnf = genericVnfOptional.get();
            VfModules vfModules = null;
            if (genericVnf.getVfModules() == null) {
                vfModules = new VfModules();
                genericVnf.setVfModules(vfModules);
            } else {
                vfModules = genericVnf.getVfModules();
            }

            vfModules.getVfModule().add(vfModule);
            cache.put(vfModuleId, vfModule);
        }
    }

    @Override
    public boolean patchVfModule(final String vnfId, final String vfModuleId, final VfModule vfModule) {
        final Optional<GenericVnf> genericVnfOptional = getGenericVnf(vnfId);
        LOGGER.info("Create vfModule for vnfId: {} and vfModuleId: {}", vnfId, vfModuleId);
        if (genericVnfOptional.isPresent()) {
            final GenericVnf cachedGenericVnf = genericVnfOptional.get();
            final VfModules vfmodules = cachedGenericVnf.getVfModules();
            LOGGER.info("vfModuleId is Matched");
            try {
                vfmodules.getVfModule().stream()
                        .filter(tempVfModule -> tempVfModule.getVfModuleId().equalsIgnoreCase(vfModuleId)).forEach(
                                tempVfModule -> tempVfModule.setOrchestrationStatus(vfModule.getOrchestrationStatus()));
                return true;
            } catch (final Exception exception) {
                LOGGER.error("Unable to update VfModule for vfModuleId: {}", vfModule, exception);
            }
        }
        LOGGER.error("Unable to find VfModule ...");
        return false;
    }

    @Override
    public Optional<Relationship> addRelationShip(final String vnfId, final String vfModuleId,
            final Relationship relationship, final String requestURI) {
        final Optional<VfModule> optional = getVfModule(vnfId, vfModuleId);
        if (optional.isPresent()) {
            final VfModule vfModule = optional.get();

            RelationshipList relationshipList = vfModule.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                vfModule.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);
            LOGGER.info("Successfully added relation to VfModule for vnfId: {} and vfModuleId: {}", vnfId, vfModuleId);

            final String relatedLink = getBiDirectionalRelationShipListRelatedLink(requestURI);

            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(VF_MODULE);
            resultantRelationship.setRelationshipLabel(USES);
            resultantRelationship.setRelatedLink(relatedLink);

            final RelationshipData genericVnfRelationshipData = new RelationshipData();
            genericVnfRelationshipData.setRelationshipKey(GENERIC_VNF_VNF_ID);
            genericVnfRelationshipData.setRelationshipValue(vnfId);
            resultantRelationship.getRelationshipData().add(genericVnfRelationshipData);

            final RelationshipData vfModuleRelationshipData = new RelationshipData();
            vfModuleRelationshipData.setRelationshipKey(VF_MODULE_VF_MODULE_ID);
            vfModuleRelationshipData.setRelationshipValue(vfModuleId);
            resultantRelationship.getRelationshipData().add(vfModuleRelationshipData);
            return Optional.of(resultantRelationship);
        }

        LOGGER.error("Unable to find VfModule ...");
        return Optional.empty();
    }

    @Override
    public boolean deleteVfModule(final String vnfId, final String vfModuleId, final String resourceVersion) {
        final Optional<GenericVnf> genericVnfOptional = getGenericVnf(vnfId);
        final Optional<VfModule> vfModuleOptional = getVfModule(vnfId, vfModuleId);
        if (genericVnfOptional.isPresent() && vfModuleOptional.isPresent()) {
            final GenericVnf genericVnf = genericVnfOptional.get();
            final VfModule vfModule = vfModuleOptional.get();
            if (genericVnf.getVfModules() != null && vfModule.getResourceVersion().equals(resourceVersion)) {
                LOGGER.info("VfModule: {} deleted from the Generic VNF: {}",vfModuleId, vnfId);
                return genericVnf.getVfModules().getVfModule().remove(vfModule);
            }
        }
        LOGGER.error("There are no VfModules associated to vnf ID: {}", vnfId);
        return false;
    }

}
