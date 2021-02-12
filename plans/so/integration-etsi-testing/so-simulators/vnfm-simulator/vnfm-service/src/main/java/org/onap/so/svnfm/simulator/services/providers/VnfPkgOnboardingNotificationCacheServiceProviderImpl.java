/*-
 * ============LICENSE_START=======================================================
 *  Copyright (C) 2021 Nordix Foundation.
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
package org.onap.so.svnfm.simulator.services.providers;

import org.onap.so.adapters.vnfmadapter.extclients.vnfm.packagemanagement.notification.model.VnfPackageOnboardingNotification;
import org.onap.so.simulator.cache.provider.AbstractCacheServiceProvider;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import java.util.Optional;

/**
 * @author Andrew Lamb (andrew.a.lamb@est.tech)
 */
@Service
public class VnfPkgOnboardingNotificationCacheServiceProviderImpl extends AbstractCacheServiceProvider
        implements VnfPkgOnboardingNotificationCacheServiceProvider {

    private static final Logger LOGGER = LoggerFactory.getLogger(VnfPkgOnboardingNotificationCacheServiceProviderImpl.class);

    @Autowired
    public VnfPkgOnboardingNotificationCacheServiceProviderImpl(final CacheManager cacheManager) {
        super(cacheManager);
    }

    @Override public void addVnfPkgOnboardingNotification(final String vnfPkgId,
            final VnfPackageOnboardingNotification vnfPackageOnboardingNotification) {
        LOGGER.debug("Adding {} to cache with vnfPkgId: {}", vnfPackageOnboardingNotification, vnfPkgId);
        getCache(Constant.VNF_PKG_ONBOARDING_NOTIFICATION_CACHE).put(vnfPkgId, vnfPackageOnboardingNotification);
    }

    @Override public Optional<VnfPackageOnboardingNotification> getVnfPkgOnboardingNotification(final String vnfPkgId) {
        LOGGER.debug("Getting vnfPkgOnboardingNotification from cache using vnfPkgId: {}", vnfPkgId);
        final Cache cache = getCache(Constant.VNF_PKG_ONBOARDING_NOTIFICATION_CACHE);
        final VnfPackageOnboardingNotification vnfPackageOnboardingNotification = cache.get(vnfPkgId, VnfPackageOnboardingNotification.class);
        if (vnfPackageOnboardingNotification != null) {
            return Optional.of(vnfPackageOnboardingNotification);
        }
        LOGGER.error("Unable to find vnfPkgOnboardingNotification in cache using vnfPkgId: {}", vnfPkgId);
        return Optional.empty();
    }
}
