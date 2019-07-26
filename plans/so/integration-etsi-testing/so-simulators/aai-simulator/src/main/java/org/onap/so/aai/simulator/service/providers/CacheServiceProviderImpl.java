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

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;
import org.onap.aai.domain.yang.Customer;
import org.onap.aai.domain.yang.ServiceInstance;
import org.onap.aai.domain.yang.ServiceInstances;
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
public class CacheServiceProviderImpl implements CacheServiceProvider {
    private static final Logger LOGGER = LoggerFactory.getLogger(CacheServiceProviderImpl.class);

    public final CacheManager cacheManager;

    @Autowired
    public CacheServiceProviderImpl(final CacheManager cacheManager) {
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
    public Optional<ServiceInstances> getServiceInstances(final String globalCustomerId, final String serviceType,
            final String serviceInstanceName) {

        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                LOGGER.info("Found service subscription ...");
                final List<ServiceInstance> serviceInstancesList = serviceSubscription.get().getServiceInstances()
                        .getServiceInstance().stream()
                        .filter(serviceInstance -> serviceInstanceName.equals(serviceInstance.getServiceInstanceName()))
                        .collect(Collectors.toList());
                if (serviceInstancesList != null && !serviceInstancesList.isEmpty()) {
                    LOGGER.info("Found {} service instances ", serviceInstancesList.size());
                    final ServiceInstances serviceInstances = new ServiceInstances();
                    serviceInstances.getServiceInstance().addAll(serviceInstancesList);
                    return Optional.of(serviceInstances);

                }
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<ServiceInstance> getServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId) {
        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                LOGGER.info("Found service subscription ...");
                final ServiceInstances serviceInstances = serviceSubscription.get().getServiceInstances();
                if (serviceInstances != null) {
                    return Optional.ofNullable(serviceInstances.getServiceInstance().stream()
                            .filter(serviceInstance -> serviceInstanceId.equals(serviceInstance.getServiceInstanceId()))
                            .findFirst().orElse(null));
                }

            }
        }
        return Optional.empty();
    }

    @Override
    public boolean putServiceInstance(final String globalCustomerId, final String serviceType,
            final String serviceInstanceId, final ServiceInstance serviceInstance) {
        LOGGER.info("Adding serviceInstance: {} in cache ...", serviceInstance, globalCustomerId);

        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final Customer value = cache.get(globalCustomerId, Customer.class);

        if (value != null) {
            final Optional<ServiceSubscription> serviceSubscription = value.getServiceSubscriptions()
                    .getServiceSubscription().stream().filter(s -> serviceType.equals(s.getServiceType())).findFirst();

            if (serviceSubscription.isPresent()) {
                final ServiceInstances serviceInstances = getServiceInstances(serviceSubscription);


                if (!serviceInstances.getServiceInstance().stream()
                        .filter(existing -> serviceInstanceId.equals(existing.getServiceInstanceId())).findFirst()
                        .isPresent()) {
                    return serviceInstances.getServiceInstance().add(serviceInstance);
                }
                LOGGER.error("Service {} already exists ....", serviceInstanceId);
                return false;
            }
            LOGGER.error("Couldn't find  service subscription with serviceType: {} in cache ", serviceType);
            return false;
        }
        LOGGER.error("Couldn't find  Customer with key: {} in cache ", globalCustomerId);
        return false;
    }

    private ServiceInstances getServiceInstances(final Optional<ServiceSubscription> optional) {
        final ServiceSubscription serviceSubscription = optional.get();
        final ServiceInstances serviceInstances = serviceSubscription.getServiceInstances();
        if (serviceInstances == null) {
            final ServiceInstances instances = new ServiceInstances();
            serviceSubscription.setServiceInstances(instances);
            return instances;
        }
        return serviceInstances;
    }

    @Override
    public void clearAll() {
        final Cache cache = cacheManager.getCache(Constant.CUSTOMER_CACHE);
        final ConcurrentHashMap<?, ?> nativeCache = (ConcurrentHashMap<?, ?>) cache.getNativeCache();
        LOGGER.info("Clear all entries from cahce: {}", cache.getName());
        nativeCache.clear();
    }

}
