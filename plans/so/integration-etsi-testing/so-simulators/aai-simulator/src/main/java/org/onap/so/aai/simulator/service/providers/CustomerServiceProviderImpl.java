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

import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceSubscription;
import org.onap.so.aai.simulator.utils.Constant;
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
public class CustomerServiceProviderImpl implements CustomerServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(CustomerServiceProviderImpl.class);

    public final CacheManager cacheManager;

    @Autowired
    public CustomerServiceProviderImpl(final CacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    @Override
    public Optional<Customer> getCustomer(final String globalCustomerId) {
        LOGGER.info("getting customer from cache using key: {}", globalCustomerId);
        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final Customer value = cache.get(globalCustomerId, Customer.class);
        if (value != null) {
            return Optional.of(value);
        }
        return Optional.empty();
    }

    @Override
    public void putCustomer(final String globalCustomerId, final Customer customer) {
        LOGGER.info("Adding customer: {} with key: {} in cache ...", customer, globalCustomerId);
        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);

        cache.put(globalCustomerId, customer);
    }

    @Override
    public Optional<ServiceSubscription> getServiceSubscription(final String globalCustomerId,
            final String serviceType) {
        LOGGER.info("getting service subscription from cache for globalCustomerId: {} and serviceType: {}",
                globalCustomerId, serviceType);

        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);

        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            return Optional.ofNullable(value.getServiceSubscriptions().getServiceSubscription().stream()
                    .filter(s -> serviceType.equals(s.getServiceType())).findFirst().orElse(null));
        }
        return Optional.empty();

    }

    @Override
    public void clearAll() {
        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final ConcurrentHashMap<?, ?> nativeCache = (ConcurrentHashMap<?, ?>) cache.getNativeCache();
        LOGGER.info("Clear all entries from cahce: {}", cache.getName());
        nativeCache.clear();
    }

}
