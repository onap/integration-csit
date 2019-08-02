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
package org.onap.so.sdncsimulator.configration;

import static org.onap.so.sdncsimulator.utils.Constants.SERVICE_TOPOLOGY_OPERATION_CACHE;
import java.util.Arrays;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author Waqas Ikram (waqas.ikram@est.tech)
 *
 */
@Configuration
public class ApplicationConfigration {

    @Bean
    public CacheManager cacheManager() {
        final SimpleCacheManager manager = new SimpleCacheManager();
        manager.setCaches(Arrays.asList(getCache(SERVICE_TOPOLOGY_OPERATION_CACHE)));
        return manager;
    }

    private Cache getCache(final String name) {
        return new ConcurrentMapCache(name);
    }
}
