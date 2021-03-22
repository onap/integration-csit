/*-
 * ============LICENSE_START=======================================================
 * Copyright 2021 Huawei Technologies Co., Ltd.
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
 * ============LICENSE_END=========================================================
 */
package org.onap.so.multicloudsimulator.configuration;

import static org.onap.so.multicloudsimulator.utils.Constants.MULTICLOUD_CACHE;
import java.util.Arrays;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApplicationConfiguration {

    @Bean
    public CacheManager cacheManager() {
        final SimpleCacheManager manager = new SimpleCacheManager();
        manager.setCaches(Arrays.asList(getCache(MULTICLOUD_CACHE)));
        return manager;
    }

    private Cache getCache(final String name) {
        return new ConcurrentMapCache(name);
    }
}
