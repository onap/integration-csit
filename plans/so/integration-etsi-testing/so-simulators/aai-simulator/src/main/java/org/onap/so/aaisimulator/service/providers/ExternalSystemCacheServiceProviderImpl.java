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

import static org.onap.so.aaisimulator.utils.CacheName.ESR_VNFM_CACHE;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.EsrSystemInfo;
import org.onap.aai.domain.yang.EsrSystemInfoList;
import org.onap.aai.domain.yang.EsrVnfm;
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
public class ExternalSystemCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements ExternalSystemCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExternalSystemCacheServiceProviderImpl.class);

    @Autowired
    public ExternalSystemCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override
    public void putEsrVnfm(final String vnfmId, final EsrVnfm esrVnfm) {
        LOGGER.info("Adding esrVnfm: {} with name to cache", esrVnfm);
        final Cache cache = getCache(ESR_VNFM_CACHE.getName());
        cache.put(vnfmId, esrVnfm);
    }

    @Override
    public Optional<EsrVnfm> getEsrVnfm(final String vnfmId) {
        LOGGER.info("getting EsrVnfm from cache using key: {}", vnfmId);
        final Cache cache = getCache(ESR_VNFM_CACHE.getName());
        final EsrVnfm value = cache.get(vnfmId, EsrVnfm.class);
        if (value != null) {
            return Optional.of(value);
        }
        LOGGER.error("Unable to find EsrVnfm in cache using vnfmId: {} ", vnfmId);
        return Optional.empty();
    }

    @Override
    public List<EsrVnfm> getAllEsrVnfm() {
        final Cache cache = getCache(ESR_VNFM_CACHE.getName());
        if (cache != null) {
            final Object nativeCache = cache.getNativeCache();
            if (nativeCache instanceof ConcurrentHashMap) {
                @SuppressWarnings("unchecked")
                final ConcurrentHashMap<Object, Object> concurrentHashMap =
                        (ConcurrentHashMap<Object, Object>) nativeCache;
                final List<EsrVnfm> result = new ArrayList<>();
                concurrentHashMap.keySet().stream().forEach(key -> {
                    final Optional<EsrVnfm> optional = getEsrVnfm(key.toString());
                    if (optional.isPresent()) {
                        result.add(optional.get());
                    }
                });
                return result;
            }
        }
        LOGGER.error("Unable to get all esr vnfms ... ");
        return Collections.emptyList();

    }

    @Override
    public Optional<EsrSystemInfoList> getEsrSystemInfoList(final String vnfmId) {
        final Optional<EsrVnfm> optional = getEsrVnfm(vnfmId);
        if (optional.isPresent()) {
            final EsrVnfm esrVnfm = optional.get();
            if (esrVnfm.getEsrSystemInfoList() != null) {
                return Optional.of(esrVnfm.getEsrSystemInfoList());
            }
            LOGGER.error("EsrSystemInfoList is null for vnfmId: {} ", vnfmId);
        }
        LOGGER.error("Unable to find EsrVnfm in cache using vnfmId: {} ", vnfmId);
        return Optional.empty();
    }

    @Override
    public boolean putEsrSystemInfo(final String vnfmId, final String esrSystemInfoId,
            final EsrSystemInfo esrSystemInfo) {
        final Optional<EsrVnfm> optional = getEsrVnfm(vnfmId);
        if (optional.isPresent()) {
            final EsrVnfm esrVnfm = optional.get();
            final List<EsrSystemInfo> esrSystemInfoList = getEsrSystemInfoList(esrVnfm);

            final Optional<EsrSystemInfo> existingEsrSystemInfo =
                    esrSystemInfoList.stream().filter(existing -> existing.getEsrSystemInfoId() != null
                            && existing.getEsrSystemInfoId().equals(esrSystemInfoId)).findFirst();
            if (existingEsrSystemInfo.isPresent()) {
                LOGGER.error("EsrSystemInfo already exists {}", existingEsrSystemInfo.get());
                return false;
            }

            return esrSystemInfoList.add(esrSystemInfo);
        }
        LOGGER.error("Unable to add EsrSystemInfo in cache for vnfmId: {} ", vnfmId);
        return false;
    }

    private List<EsrSystemInfo> getEsrSystemInfoList(final EsrVnfm esrVnfm) {
        EsrSystemInfoList esrSystemInfoList = esrVnfm.getEsrSystemInfoList();
        if (esrSystemInfoList == null) {
            esrSystemInfoList = new EsrSystemInfoList();
            esrVnfm.setEsrSystemInfoList(esrSystemInfoList);
        }
        return esrSystemInfoList.getEsrSystemInfo();
    }

    @Override
    public void clearAll() {
        clearCache(ESR_VNFM_CACHE.getName());

    }

}
