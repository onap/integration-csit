package org.onap.so.svnfm.simulator.config;

import java.util.ArrayList;
import java.util.List;
import org.onap.so.svnfm.simulator.constants.Constant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class ApplicationConfig implements ApplicationRunner {
    private static final Logger LOGGER = LoggerFactory.getLogger(ApplicationConfig.class);

    private static final String PORT = "local.server.port";

    @Value("${server.dns.name:so-vnfm-simulator.onap}")
    private String serverDnsName;

    @Value("${server.request.grant.auth:oauth}")
    private String grantAuth;

    @Autowired
    private Environment environment;

    private String baseUrl;

    @Override
    public void run(final ApplicationArguments args) throws Exception {
        baseUrl = "http://" + serverDnsName + ":" + environment.getProperty(PORT);
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public String getGrantAuth() {
        return grantAuth;
    }

    @Bean
    public CacheManager cacheManager() {
        final Cache inlineResponse201 = getCache(Constant.IN_LINE_RESPONSE_201_CACHE);
        final Cache vnfPkgOnboardingNotificationCache = getCache(Constant.VNF_PKG_ONBOARDING_NOTIFICATION_CACHE);
        final List<Cache> caches = new ArrayList<>();
        caches.add(inlineResponse201);
        caches.add(vnfPkgOnboardingNotificationCache);
        final SimpleCacheManager manager = new SimpleCacheManager();
        manager.setCaches(caches);
        return manager;
    }

    private Cache getCache(final String name) {
        LOGGER.info("Creating cache with name: {}", name);
        return new ConcurrentMapCache(name);
    }
}
