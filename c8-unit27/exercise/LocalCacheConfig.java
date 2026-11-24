package com.tiffinbox.web;

import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

/**
 * The exercise's (Course 8, unit 27): a local cache under "dev" as well - a second CacheManager bean, a Caffeine one named
 * localCaches, beside the Redis one Boot builds for the profile. Copied into a copy of after/'s src/main by exercise/README.md.
 */
@Configuration(proxyBeanMethods = false)
@Profile("dev")
public class LocalCacheConfig {

    @Bean
    CaffeineCacheManager localCaches() {
        return new CaffeineCacheManager();
    }
}
