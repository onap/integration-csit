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
import static org.onap.so.aaisimulator.utils.Constants.BI_DIRECTIONAL_RELATIONSHIP_LIST_URL;
import static org.onap.so.aaisimulator.utils.Constants.COMPOSED_OF;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF_VNF_ID;
import static org.onap.so.aaisimulator.utils.Constants.GENERIC_VNF_VNF_NAME;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.GenericVnf;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.so.simulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

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
    public boolean addRelationShip(final String vnfId, final Relationship relationship) {
        final Optional<GenericVnf> optional = getGenericVnf(vnfId);
        if (optional.isPresent()) {
            final GenericVnf genericVnf = optional.get();
            RelationshipList relationshipList = genericVnf.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                genericVnf.setRelationshipList(relationshipList);
            }
            return relationshipList.getRelationship().add(relationship);
        }
        LOGGER.error("Unable to find GenericVnf ...");
        return false;
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
                    final GenericVnf value = cache.get(key, GenericVnf.class);
                    final String genericVnfName = value.getVnfName();
                    if (value != null && genericVnfName.equals(vnfName)) {
                        final String genericVnfId = value.getVnfId();
                        LOGGER.info("Found matching vnf for name: {}, vnf-id: {}", genericVnfName, genericVnfId);
                        return Optional.of(genericVnfId);
                    }
                }
            }
        }
        LOGGER.info("No match found for vnf name: {}", vnfName);
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
                final Relationship outGoingRelationShip = getRelationship(requestUriString, genericVnf);
                final Optional<Relationship> optionalRelationship = httpRestServiceProvider.put(incomingHeader,
                        outGoingRelationShip, targetUrl, Relationship.class);
                if (optionalRelationship.isPresent()) {
                    final Relationship resultantRelationship = optionalRelationship.get();
                    if (addRelationShip(vnfId, resultantRelationship)) {
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

    private String getTargetUrl(final String targetBaseUrl, final String relatedLink) {
        return UriComponentsBuilder.fromUriString(targetBaseUrl).path(relatedLink)
                .path(BI_DIRECTIONAL_RELATIONSHIP_LIST_URL).toUriString();
    }

    private Relationship getRelationship(final String relatedLink, final GenericVnf genericVnf) {
        final Relationship relationShip = new Relationship();
        relationShip.setRelatedTo(GENERIC_VNF);
        relationShip.setRelationshipLabel(COMPOSED_OF);
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
        clearCahce(GENERIC_VNF_CACHE.getName());
    }

}
