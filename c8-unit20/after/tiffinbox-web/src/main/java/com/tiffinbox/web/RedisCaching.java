package com.tiffinbox.web;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.cache.autoconfigure.CacheProperties;
import org.springframework.boot.cache.autoconfigure.RedisCacheManagerBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.RedisSerializationContext.SerializationPair;
import org.springframework.data.redis.serializer.RedisSerializer;

/**
 * How Redis keeps TiffinBox's cache: the cache writer, and the serializer every cached value crosses.
 *
 * <p>Course 8, unit 11: read only while the cache is Redis's - {@code spring.cache.type: redis}, which application-dev.yaml sets for
 * the profile "dev". The default run's {@code spring.cache.type: caffeine} (application.yaml) builds neither bean: its cache is
 * Caffeine's, in the JVM, and it needs no Redis. Under Spring's AOT step, and so in the native binary, the condition is fixed when
 * the jar is built; the profile "dev" is a JVM run's (../c8-unit11, anchor).
 *
 * <p>Course 8, unit 11: the cache writer TiffinBox gives Redis. Boot's own RedisCacheManager is built with the writer Boot builds
 * over Lettuce, whose puts and clears return before Redis has them: a read right after a write may miss, and a read right after
 * {@code @CacheEvict(allEntries = true)} may still return the old list (../c8-unit11, writer). {@code immediateWrites()} is the switch
 * that makes each write finish before the call returns; {@code enableLocking()} makes the writer hold a lock in Redis while it
 * writes. The customizer below hands Boot's builder that writer, and Boot's builder keeps everything else it sets.
 *
 * <p>Course 8, unit 11: the serializer - turning the object into the bytes the store keeps. Boot's default for Redis is Java's
 * own serialization, which refuses TiffinBox's Customer record (not Serializable, and kept that way) at every put
 * (../c8-unit11, jdk). {@code RedisSerializer.json()} is Spring Data Redis's GenericJacksonJsonRedisSerializer on Jackson 3: JSON,
 * with each object's class in an "@class" field and a list's class beside it (../c8-unit11, json). That serializer turns
 * Jackson's unknown-property check off itself: bytes an earlier build wrote with a field this build renamed come back with that
 * field empty, and no exception (../c8-unit11, renamed). The configuration is built from Boot's own CacheProperties, so
 * {@code spring.cache.redis.time-to-live}, {@code cache-null-values}, {@code key-prefix} and {@code use-key-prefix} still apply: a
 * RedisCacheConfiguration bean replaces Boot's, and one that ignores them drops them without a word (../c8-unit11, ttlbean).
 */
@Configuration(proxyBeanMethods = false)
@ConditionalOnProperty(name = "spring.cache.type", havingValue = "redis")
public class RedisCaching {

    /** Course 8, unit 11: the cache writer TiffinBox gives Redis - each write done before the call returns, under a lock. */
    @Bean
    RedisCacheManagerBuilderCustomizer immediateLockingWriter(RedisConnectionFactory connections) {
        return builder -> builder.cacheWriter(RedisCacheWriter.create(connections, writer -> writer.immediateWrites().enableLocking()));
    }

    /** Course 8, unit 11: JSON values, and Boot's spring.cache.redis.* settings applied as Boot's own configuration applies them. */
    @Bean
    RedisCacheConfiguration redisCacheConfiguration(CacheProperties properties) {
        CacheProperties.Redis redis = properties.getRedis();
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .serializeValuesWith(SerializationPair.fromSerializer(RedisSerializer.json()));
        if (redis.getTimeToLive() != null) {
            config = config.entryTtl(redis.getTimeToLive());
        }
        if (redis.getKeyPrefix() != null) {
            config = config.prefixCacheNameWith(redis.getKeyPrefix());
        }
        if (!redis.isCacheNullValues()) {
            config = config.disableCachingNullValues();
        }
        if (!redis.isUseKeyPrefix()) {
            config = config.disableKeyPrefix();
        }
        return config;
    }
}
