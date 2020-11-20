/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2020 Nordix Foundation.
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
package org.onap.aaisimulator.service.providers;

import static org.onap.aaisimulator.utils.CacheName.SERVICE_INSTANCE_CACHE;

import java.util.Optional;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aaisimulator.cache.provider.AbstractCacheServiceProvider;
import org.onap.aaisimulator.utils.ShallowBeanCopy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

@Service
public class ServiceInstanceCacheProviderImpl extends AbstractCacheServiceProvider implements
    ServiceInstanceCacheProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(ServiceInstanceCacheProviderImpl.class);

    private final Cache cache;

    @Autowired
    public ServiceInstanceCacheProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
        cache = getCache(SERVICE_INSTANCE_CACHE.getName());
    }

    @Override
    public boolean patchServiceInstance(String globalCustomerId, ServiceInstance serviceInstance) {
        final Optional<ServiceInstance> svcInstance = getServiceInstance(globalCustomerId);
        if (svcInstance.isPresent()) {
            final ServiceInstance cachedSvcInstance = svcInstance.get();
            try {
                ShallowBeanCopy.copy(serviceInstance, cachedSvcInstance);
                return true;
            } catch (final Exception exception) {
                LOGGER.error("Unable to update ServiceInstance for globalCustomerId: {}", globalCustomerId, exception);
            }
        }
        LOGGER.error("Unable to find ServiceInstance for globalCustomerId : {}", globalCustomerId);
        return false;
    }

    @Override
    public Optional<ServiceInstance> getServiceInstance(final String globalCustomerId) {
        LOGGER.info("Getting Service Instance with key: {} in cache ...", globalCustomerId);
        final ServiceInstance svcInstance = cache.get(globalCustomerId, ServiceInstance.class);
        return Optional.ofNullable(svcInstance);
    }

    @Override
    public boolean putServiceInstance(String globalCustomerId, ServiceInstance serviceInstance) {
        LOGGER.info("Adding ServiceInstance: {} with key: {} in cache ...", serviceInstance, globalCustomerId);
        cache.put(globalCustomerId, serviceInstance);
        return true;
    }
}