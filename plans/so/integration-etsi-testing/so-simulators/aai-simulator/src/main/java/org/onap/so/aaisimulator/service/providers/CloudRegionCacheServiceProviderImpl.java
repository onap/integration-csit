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

import static org.onap.so.aaisimulator.utils.CacheName.CLOUD_REGION_CACHE;
import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGION;
import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGION_CLOUD_OWNER;
import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGION_CLOUD_REGION_ID;
import static org.onap.so.aaisimulator.utils.Constants.CLOUD_REGION_OWNER_DEFINED_TYPE;
import static org.onap.so.aaisimulator.utils.Constants.LOCATED_IN;
import java.util.List;
import java.util.Optional;
import org.onap.aai.domain.yang.CloudRegion;
import org.onap.aai.domain.yang.RelatedToProperty;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipData;
import org.onap.aai.domain.yang.RelationshipList;
import org.onap.so.aaisimulator.models.CloudRegionKey;
import org.onap.so.simulator.cache.provider.AbstractCacheServiceProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Service
public class CloudRegionCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements CloudRegionCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(CloudRegionCacheServiceProviderImpl.class);


    @Autowired
    public CloudRegionCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public void putCloudRegion(final CloudRegionKey cloudRegionKey, final CloudRegion cloudRegion) {
        LOGGER.info("Adding CloudRegion to cache with key: {} ...", cloudRegionKey);
        final Cache cache = getCache(CLOUD_REGION_CACHE.getName());
        cache.put(cloudRegionKey, cloudRegion);

    }

    @Override
    public Optional<CloudRegion> getCloudRegion(final CloudRegionKey cloudRegionKey) {
        LOGGER.info("getting CloudRegion from cache using key: {}", cloudRegionKey);
        final Cache cache = getCache(CLOUD_REGION_CACHE.getName());
        final CloudRegion value = cache.get(cloudRegionKey, CloudRegion.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find CloudRegion in cache using key:{} ", cloudRegionKey);
        return Optional.empty();
    }

    @Override
    public Optional<Relationship> addRelationShip(final CloudRegionKey key, final Relationship relationship,
            final String requestUri) {
        final Optional<CloudRegion> optional = getCloudRegion(key);
        if (optional.isPresent()) {
            final CloudRegion cloudRegion = optional.get();
            RelationshipList relationshipList = cloudRegion.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                cloudRegion.setRelationshipList(relationshipList);
            }
            relationshipList.getRelationship().add(relationship);

            LOGGER.info("Successfully added relation to CloudRegion with key: {}", key);


            final Relationship resultantRelationship = new Relationship();
            resultantRelationship.setRelatedTo(CLOUD_REGION);
            resultantRelationship.setRelationshipLabel(LOCATED_IN);
            resultantRelationship.setRelatedLink(requestUri);

            final List<RelationshipData> relationshipDataList = resultantRelationship.getRelationshipData();
            relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_OWNER, cloudRegion.getCloudOwner()));
            relationshipDataList.add(getRelationshipData(CLOUD_REGION_CLOUD_REGION_ID, cloudRegion.getCloudRegionId()));

            final List<RelatedToProperty> relatedToPropertyList = resultantRelationship.getRelatedToProperty();

            final RelatedToProperty relatedToProperty = new RelatedToProperty();
            relatedToProperty.setPropertyKey(CLOUD_REGION_OWNER_DEFINED_TYPE);
            relatedToProperty.setPropertyValue(cloudRegion.getOwnerDefinedType());
            relatedToPropertyList.add(relatedToProperty);

            return Optional.of(resultantRelationship);

        }
        LOGGER.error("Unable to find CloudRegion using key: {} ...", key);
        return Optional.empty();
    }

    private RelationshipData getRelationshipData(final String key, final String value) {
        final RelationshipData relationshipData = new RelationshipData();
        relationshipData.setRelationshipKey(key);
        relationshipData.setRelationshipValue(value);
        return relationshipData;
    }

    @Override
    public void clearAll() {
        clearCahce(CLOUD_REGION_CACHE.getName());

    }

}
