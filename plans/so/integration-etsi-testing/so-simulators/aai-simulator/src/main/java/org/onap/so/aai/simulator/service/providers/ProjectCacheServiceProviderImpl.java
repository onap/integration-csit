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
package org.onap.so.aai.simulator.service.providers;

import static org.onap.so.aai.simulator.utils.Constants.PROJECT_CACHE;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.Project;
import org.onap.aai.domain.yang.Relationship;
import org.onap.aai.domain.yang.RelationshipList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

/**
 * @author waqas.ikram@ericsson.com
 *
 */
@Service
public class ProjectCacheServiceProviderImpl implements ProjectCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProjectCacheServiceProviderImpl.class);

    public final CacheManager cacheManager;

    @Autowired
    public ProjectCacheServiceProviderImpl(final CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    @Override
    public void putProject(final String projectName, final Project project) {
        LOGGER.info("Adding project: {} with name to cache", project, projectName);
        final Cache cache = cacheManager.getCache(PROJECT_CACHE);
        cache.put(projectName, project);
    }


    @Override
    public Optional<Project> getProject(final String projectName) {
        LOGGER.info("getting project from cache using key: {}", projectName);
        final Cache cache = cacheManager.getCache(PROJECT_CACHE);
        final Project value = cache.get(projectName, Project.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public boolean putProjectRelationShip(final String projectName, final Relationship relationship) {
        final Cache cache = cacheManager.getCache(PROJECT_CACHE);
        final Project value = cache.get(projectName, Project.class);
        if (value != null) {
            RelationshipList relationshipList = value.getRelationshipList();
            if (relationshipList == null) {
                relationshipList = new RelationshipList();
                value.setRelationshipList(relationshipList);
            }
            return relationshipList.getRelationship().add(relationship);
        }
        return false;

    }

    @Override
    public void clearAll() {
        final Cache cache = cacheManager.getCache(PROJECT_CACHE);
        final ConcurrentHashMap<?, ?> nativeCache = (ConcurrentHashMap<?, ?>) cache.getNativeCache();
        LOGGER.info("Clear all entries from cahce: {}", cache.getName());
        nativeCache.clear();
    }
}
