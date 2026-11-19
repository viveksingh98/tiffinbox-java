package com.tiffinbox.web;

import com.tiffinbox.CustomerAdded;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.connection.stream.RecordId;
import org.springframework.data.redis.connection.stream.StreamRecords;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.LinkedHashMap;

/**
 * Course 8, unit 16: the kitchen's events, a Redis stream under the profile "dev". A stream is a list of entries Redis keeps, each
 * with an id Redis gives it and its own fields; readers read it from any entry on, and an entry stays in the stream after it is
 * read. Every customer TiffinBox stores becomes one entry of tiffinbox:kitchen-events - XADD, three fields in this order: type
 * (customer-added), name and mealType. The fields are written from a LinkedHashMap, so the entry holds them in the order they were
 * put: the order a Map.of gives moved from one JVM to the next (the Section 3 probe), and redis-cli's XRANGE prints what was written.
 *
 * <p>Who tells it, and when: CustomerRepository's add publishes CustomerAdded inside its transaction, and this class hears it with
 * {@code @TransactionalEventListener} - after the commit, its default phase, as CustomerFeed does. A customer whose row never
 * commits reaches no stream: add of a name the table already holds is refused (409), and the stream's length does not move
 * (../c8-unit16, anchor). The flip side, named here and not measured: the XADD runs after the row is stored, so a customer stored
 * while Redis is down gets no entry - the row commits and the XADD fails after it. Two stores written one after the other is the
 * dual write; unit 24 and Course 13 take it up.
 *
 * <p>The seed's customers are Flyway's (V2__seed.sql inserts them), not add's: a start writes nothing to this stream, and the
 * stream is the one thing in Redis the start does not rebuild (compose.yaml's note; ../c8-unit16, anchor and persist).
 *
 * <p>Why the profile "dev": under "dev" Redis is required already (Leaderboard, KitchenOrders); this class needs it only at the
 * XADD, after a commit. The default run has no KitchenEvents bean and needs no Redis (../c8-unit16, default). Consumer groups,
 * Pub/Sub and a listener container are the unit's harness, never TiffinBox's.
 *
 * <p>{@link #write} is the XADD itself, a method the test calls without a transaction (RedisDatastoreIT); {@link #stored} is the
 * listener that calls it.
 */
@Component
@Profile("dev")
class KitchenEvents {

    /** The stream's key, as redis-cli reads it. */
    static final String KEY = "tiffinbox:kitchen-events";

    private final StringRedisTemplate redis;

    KitchenEvents(StringRedisTemplate redis) {
        this.redis = redis;
    }

    /** CustomerRepository's add committed: one entry for its customer. */
    @TransactionalEventListener
    void stored(CustomerAdded e) {
        write(e);
    }

    /** XADD tiffinbox:kitchen-events * type customer-added name &lt;name&gt; mealType &lt;mealType&gt; - the id is the one Redis gave. */
    RecordId write(CustomerAdded e) {
        var fields = new LinkedHashMap<String, String>();
        fields.put("type", "customer-added");
        fields.put("name", e.customer().name());
        fields.put("mealType", e.customer().mealType());
        return redis.opsForStream().add(StreamRecords.mapBacked(fields).withStreamKey(KEY));
    }
}
