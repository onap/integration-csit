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

import static org.onap.so.aaisimulator.utils.CacheName.LINES_OF_BUSINESS_CACHE;
import java.util.Optional;
import org.onap.aai.domain.yang.LineOfBusiness;
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
public class LinesOfBusinessCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements LinesOfBusinessCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(LinesOfBusinessCacheServiceProviderImpl.class);

    @Autowired
    public LinesOfBusinessCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public void putLineOfBusiness(final String lineOfBusinessName, final LineOfBusiness lineOfBusiness) {
        LOGGER.info("Adding LineOfBusiness to cache with key: {} ...", lineOfBusinessName);
        final Cache cache = getCache(LINES_OF_BUSINESS_CACHE.getName());
        cache.put(lineOfBusinessName, lineOfBusiness);

    }

    @Override
    public Optional<LineOfBusiness> getLineOfBusiness(final String lineOfBusinessName) {
        LOGGER.info("getting LineOfBusiness from cache using key: {}", lineOfBusinessName);
        final Cache cache = getCache(LINES_OF_BUSINESS_CACHE.getName());
        final LineOfBusiness value = cache.get(lineOfBusinessName, LineOfBusiness.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find LineOfBusiness in cache using key:{} ", lineOfBusinessName);
        return Optional.empty();
    }

    @Override
    public void clearAll() {
        clearCahce(LINES_OF_BUSINESS_CACHE.getName());
    }

}
