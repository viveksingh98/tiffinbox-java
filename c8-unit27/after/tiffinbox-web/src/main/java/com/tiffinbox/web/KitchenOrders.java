package com.tiffinbox.web;

import org.springframework.data.repository.CrudRepository;

import java.util.List;

/**
 * Course 8, unit 15: the kitchen's orders, a Spring Data Redis repository - registered under the profile "dev" by RedisDatastore,
 * never on the default run (application.yaml: spring.data.redis.repositories.enabled: false). CrudRepository's methods are Redis
 * commands on the hash and its sets: save is DEL, HMSET and an SADD per set (EXPIRE too, when the order carries a time to live);
 * count() is SCARD kitchen-order; findAll() is SMEMBERS kitchen-order, then HGETALL and TTL for each id.
 *
 * <p>The three finders are derived from their names, on the two indexed fields: findByMealType is SINTER of one index set, then
 * HGETALL for each id it holds; findByCustomerAndMealType is one SINTER of two index sets. An id whose hash is gone is dropped by
 * a finder and comes back as null from findAll() (../c8-unit15, stale).
 */
public interface KitchenOrders extends CrudRepository<KitchenOrder, String> {

    List<KitchenOrder> findByMealType(String mealType);

    List<KitchenOrder> findByCustomer(String customer);

    List<KitchenOrder> findByCustomerAndMealType(String customer, String mealType);
}
