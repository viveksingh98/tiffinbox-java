package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.cache.transaction.TransactionAwareCacheDecorator;
import org.springframework.cache.transaction.TransactionAwareCacheManagerProxy;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.mock.env.MockEnvironment;

/**
 * Course 9, unit 04: TransactionAwareCaching's switch, without a context - the post-processor called the way Spring calls it. On (the
 * default): a plain manager comes back wrapped once, and its caches are transaction-aware decorators. Off: the manager comes back as it
 * went in. A RedisCacheManager built transactionAware() is returned unchanged: never decorated twice (two nested decorators lose the
 * inner clear - the harness's self-test measures that, ../c9-unit04). The Redis connection factory is never started: nothing connects.
 */
class TransactionAwareCachingTest {

    static BeanPostProcessor bpp(String value) {
        MockEnvironment env = new MockEnvironment();
        if (value != null) env.setProperty("tiffinbox.cache.transaction-aware", value);
        return TransactionAwareCaching.transactionAwareCacheManager(env);
    }

    @Test
    void onByDefaultAPlainManagerIsWrappedOnce() {
        CaffeineCacheManager caffeine = new CaffeineCacheManager("customers", "customer");
        Object out = bpp(null).postProcessAfterInitialization(caffeine, "cacheManager");
        assertThat(out).isInstanceOf(TransactionAwareCacheManagerProxy.class);
        assertThat(((TransactionAwareCacheManagerProxy) out).getCache("customers")).isInstanceOf(TransactionAwareCacheDecorator.class);
        assertThat(bpp(null).postProcessAfterInitialization(out, "cacheManager")).isSameAs(out);
    }

    @Test
    void offTheManagerIsLeftAsBuilt() {
        CaffeineCacheManager caffeine = new CaffeineCacheManager("customers");
        assertThat(bpp("false").postProcessAfterInitialization(caffeine, "cacheManager")).isSameAs(caffeine);
    }

    @Test
    void aTransactionAwareRedisManagerIsNotWrappedAgain() {
        LettuceConnectionFactory never = new LettuceConnectionFactory();
        RedisCacheManager aware = RedisCacheManager.builder(RedisCacheWriter.nonLockingRedisCacheWriter(never)).transactionAware().build();
        RedisCacheManager plain = RedisCacheManager.builder(RedisCacheWriter.nonLockingRedisCacheWriter(never)).build();
        assertThat(bpp(null).postProcessAfterInitialization(aware, "cacheManager")).isSameAs(aware);
        assertThat(bpp(null).postProcessAfterInitialization(plain, "cacheManager")).isInstanceOf(TransactionAwareCacheManagerProxy.class);
    }
}
