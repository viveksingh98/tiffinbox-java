package com.tiffinbox.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.RedisKeyValueAdapter.EnableKeyspaceEvents;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;

/**
 * Course 8, unit 15: Redis as a datastore for the kitchen's orders - the one place TiffinBox registers a Spring Data Redis
 * repository (KitchenOrders), under the profile "dev". application.yaml switches Boot's own Redis repositories off
 * (spring.data.redis.repositories.enabled: false), so the default run has none and needs no Redis.
 *
 * <p>Why ON_STARTUP: with keyspace events OFF, Spring Data Redis's default, a hash whose time to live ends is gone, and its ids stay
 * in kitchen-order and in the index sets - count() still counts them and findAll() returns a null for each (../c8-unit15, stale).
 * ON_STARTUP starts a listener with the repository: Redis tells it when a hash is gone, and it removes the id from the sets.
 *
 * <p>Its condition: it removes an index entry when Redis tells it a hash is gone - while a TiffinBox under "dev" is running. A time
 * to live that ended while TiffinBox was down leaves the index as it was until the next start re-saves those ids; a fresh JVM that
 * only listens repairs nothing it did not hear (../c8-unit15, nolisten). TiffinBoxServer's start saves the same ids each time.
 *
 * <p>Why the profile "dev": the listener's start needs Redis - with Redis absent the start stops (../c8-unit15, startstop) - and it
 * needs a server that answers CONFIG SET: it writes notify-keyspace-events on the server, and a server that refuses CONFIG stops
 * the start too (../c8-unit15, noconfig). That setting is the server's: it outlives the JVM that wrote it (redis-cli CONFIG GET
 * notify-keyspace-events reads xE after TiffinBox has stopped).
 */
@Configuration(proxyBeanMethods = false)
@Profile("dev")
@EnableRedisRepositories(basePackageClasses = KitchenOrders.class, enableKeyspaceEvents = EnableKeyspaceEvents.ON_STARTUP)
class RedisDatastore {
}
