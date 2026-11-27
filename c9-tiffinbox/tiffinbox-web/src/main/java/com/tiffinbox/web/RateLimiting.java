package com.tiffinbox.web;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.BucketConfiguration;
import io.github.bucket4j.distributed.ExpirationAfterWriteStrategy;
import io.github.bucket4j.distributed.proxy.ProxyManager;
import io.github.bucket4j.redis.lettuce.Bucket4jLettuce;
import io.lettuce.core.RedisClient;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.env.Environment;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import tools.jackson.databind.json.JsonMapper;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Course 9, unit 19: the rate limit's registration and its two stores - {@link RateLimitFilter} on {@code /api/v1/*} and nothing
 * else (the old surface, the pages, /actuator and /v3/api-docs are never counted), at order -95: after Spring Security's filter chain
 * (-100 by Boot's default, SecurityFilterProperties.DEFAULT_FILTER_ORDER) and before the Idempotency-Key filter (-90,
 * {@link IdempotencyKeys}), so a refused request writes no key row.
 *
 * <p>The settings, both required (application.yaml): tiffinbox.rate-limit.capacity, the requests one address may send per period, and
 * tiffinbox.rate-limit.refill-period, after which the bucket is full again (refilled as a whole, Bucket4j's refillIntervally). The
 * start logs them once.
 *
 * <p>The store is the profile's choice, never a setting: on the default run each address's bucket lives in this JVM (a map, never
 * evicted; it dies with the JVM, and two JVMs count apart); under "dev" it lives in Redis, through the client of Boot's own
 * LettuceConnectionFactory, under the key tiffinbox:api-rate:&lt;address&gt; - so every JVM on that Redis counts against one bucket;
 * Redis drops the key once the bucket would be full again (basedOnTimeForRefillingBucketUpToMax). The default run opens no Redis
 * connection.
 */
@Configuration(proxyBeanMethods = false)
class RateLimiting {

    static final int ORDER = -95;
    static final String KEY_PREFIX = "tiffinbox:api-rate:";
    private static final System.Logger LOG = System.getLogger("tiffinbox.ratelimit");

    static BucketConfiguration configuration(Environment env) {
        long capacity = env.getRequiredProperty("tiffinbox.rate-limit.capacity", Long.class);
        Duration period = env.getRequiredProperty("tiffinbox.rate-limit.refill-period", Duration.class);
        return BucketConfiguration.builder()
                .addLimit(Bandwidth.builder().capacity(capacity).refillIntervally(capacity, period).build())
                .build();
    }

    @Bean
    @Profile("!dev")
    RateLimitFilter.Buckets rateLimitBucketsInTheJvm(Environment env) {
        BucketConfiguration conf = configuration(env);
        Map<String, Bucket> buckets = new ConcurrentHashMap<>();
        LOG.log(System.Logger.Level.INFO, "rate limit: capacity {0} per refill period {1}, the buckets in this JVM",
                env.getRequiredProperty("tiffinbox.rate-limit.capacity"), env.getRequiredProperty("tiffinbox.rate-limit.refill-period"));
        return address -> buckets.computeIfAbsent(address, a -> Bucket.builder().addLimit(conf.getBandwidths()[0]).build());
    }

    @Bean
    @Profile("dev")
    RateLimitFilter.Buckets rateLimitBucketsInRedis(Environment env, LettuceConnectionFactory redis) {
        BucketConfiguration conf = configuration(env);
        Duration period = env.getRequiredProperty("tiffinbox.rate-limit.refill-period", Duration.class);
        RedisClient client = (RedisClient) redis.getNativeClient();
        ProxyManager<byte[]> proxies = Bucket4jLettuce.casBasedBuilder(client)
                .expirationAfterWrite(ExpirationAfterWriteStrategy.basedOnTimeForRefillingBucketUpToMax(period))
                .build();
        LOG.log(System.Logger.Level.INFO, "rate limit: capacity {0} per refill period {1}, the buckets in Redis ({2}*, through {3})",
                env.getRequiredProperty("tiffinbox.rate-limit.capacity"), env.getRequiredProperty("tiffinbox.rate-limit.refill-period"),
                KEY_PREFIX, client.getClass().getSimpleName() + " of " + redis.getClass().getSimpleName());
        return address -> proxies.builder().build((KEY_PREFIX + address).getBytes(StandardCharsets.UTF_8), () -> conf);
    }

    @Bean
    FilterRegistrationBean<RateLimitFilter> rateLimitFilter(RateLimitFilter.Buckets buckets, JsonMapper json) {
        FilterRegistrationBean<RateLimitFilter> registration = new FilterRegistrationBean<>(new RateLimitFilter(buckets, json));
        registration.setOrder(ORDER);
        registration.addUrlPatterns("/api/v1/*");
        registration.setName("rateLimitFilter");
        return registration;
    }
}
