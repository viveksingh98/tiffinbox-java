package com.tiffinbox.web;

import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;
import org.springframework.data.redis.core.index.Indexed;

/**
 * Course 8, unit 15 - Spring Data Redis repositories: an order on the kitchen's rail, kept in Redis, where no table holds it. The
 * customers stay in the database, the system of record; what Redis keeps here is the order the start placed - whose it is, the
 * customer's meal type, and its value (meals times price, the number the leaderboard and /kitchen add up).
 *
 * <p>{@code @RedisHash("kitchen-order")}: Spring Data Redis writes each order as one hash, kitchen-order:&lt;id&gt;, and keeps the
 * ids in a set, kitchen-order. {@code @Indexed} on customer and mealType adds a secondary index - a set per indexed value, holding
 * the ids that have it (kitchen-order:customer:Ravi, kitchen-order:mealType:VEG) - and one more set per order, kitchen-order:&lt;id&gt;:idx,
 * naming the index sets its id is in. A derived finder (KitchenOrders) is a set intersection of those sets that redis-cli can read.
 *
 * <p>{@code @TimeToLive}: the time to live the entity carries, the whole number Redis's EXPIRE takes for the hash. null is no time to live,
 * Spring Data's own meaning: the hash is saved untimed (redis-cli's PTTL answers -1). TiffinBoxServer sets it from the setting
 * tiffinbox.kitchen-order-ttl. When it ends the hash is gone, and its index sets stay as they were unless a running repository is
 * listening: RedisDatastore says when that is.
 *
 * <p>Why the profile "dev": the repository that saves it, RedisDatastore's, exists under "dev" only, where Redis is required; the
 * default run has neither the repository nor any need of Redis (../c8-unit15, default).
 */
@RedisHash("kitchen-order")
public class KitchenOrder {

    @Id
    private String id;

    @Indexed
    private String customer;

    @Indexed
    private String mealType;

    private int value;

    @TimeToLive
    private Long ttl;

    /** Spring Data Redis reads a hash back through this constructor and the setters. */
    public KitchenOrder() {
    }

    public KitchenOrder(String id, String customer, String mealType, int value, Long ttl) {
        this.id = id;
        this.customer = customer;
        this.mealType = mealType;
        this.value = value;
        this.ttl = ttl;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCustomer() {
        return customer;
    }

    public void setCustomer(String customer) {
        this.customer = customer;
    }

    public String getMealType() {
        return mealType;
    }

    public void setMealType(String mealType) {
        this.mealType = mealType;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    public Long getTtl() {
        return ttl;
    }

    public void setTtl(Long ttl) {
        this.ttl = ttl;
    }

    /** The order without its time to live, which is a configured setting: KitchenOrder[id,customer,mealType,value]. */
    @Override
    public String toString() {
        return "KitchenOrder[" + id + "," + customer + "," + mealType + "," + value + "]";
    }
}
