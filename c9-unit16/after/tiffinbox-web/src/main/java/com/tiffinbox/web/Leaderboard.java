package com.tiffinbox.web;

import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

/**
 * Course 8, unit 14 - Redis as a datastore, Section 3's first change to this folder: the kitchen's leaderboard, a sorted set in
 * Redis that no table holds. A sorted set keeps its members in order by a number Redis stores beside each - here a customer's name
 * and the value of the orders the kitchen cooked for that customer. TiffinBoxServer.start() fills it from the orders it places: one
 * ZINCRBY per order, so the four scores add up to the kitchen's own value (/kitchen's ordersValue, and the start's log line).
 * GET /leaderboard reads it back, highest score first (ZREVRANGE ... WITHSCORES), as a JSON object in the order Redis returned.
 *
 * <p>Why StringRedisTemplate: its keys and members are the strings themselves, so redis-cli finds tiffinbox:leaderboard and Ravi by
 * name. Boot's other template bean, redisTemplate, is a RedisTemplate of Object and Object whose serializer is
 * JdkSerializationRedisSerializer: the same ZINCRBY through it writes a key and members that begin with Java serialization's own
 * bytes, and redis-cli's ZSCORE tiffinbox:leaderboard Ravi finds nothing - no exception anywhere (../c8-unit14, trap). The
 * serializer did that, not Redis. RedisCaching's JSON serializer is the cache's alone; it never reaches either template.
 *
 * <p>Why the start resets it: ZINCRBY adds, so a second start against the same Redis would add every order again and double each
 * score (../c8-unit14, twice). reset() deletes the key before the fill; three starts in a row print the same board.
 *
 * <p>Why the profile "dev": under the profile "dev", Redis is required - Compose starts it beside Postgres, and without it the
 * start stops: TiffinBoxServer's fill names RedisConnectionFailureException, and TiffinBox does not start (../c8-unit14, absent).
 * The default run has no Leaderboard bean, no /leaderboard (404) and needs no Redis (../c8-unit14, default).
 */
@RestController
@Profile("dev")
public class Leaderboard {

    /** The sorted set's key, as redis-cli reads it. */
    static final String KEY = "tiffinbox:leaderboard";

    private final StringRedisTemplate redis;

    Leaderboard(StringRedisTemplate redis) {
        this.redis = redis;
    }

    /** DEL tiffinbox:leaderboard: the board starts empty. */
    public void reset() {
        redis.delete(KEY);
    }

    /** ZINCRBY tiffinbox:leaderboard value customer: one order's value added to the customer's score. */
    public void record(String customer, double value) {
        redis.opsForZSet().incrementScore(KEY, customer, value);
    }

    /** ZREVRANGE tiffinbox:leaderboard 0 -1 WITHSCORES, highest first, kept in the order Redis returned (a LinkedHashMap). */
    @GetMapping("/leaderboard")
    Map<String, Double> board() {
        Set<ZSetOperations.TypedTuple<String>> ranked = redis.opsForZSet().reverseRangeWithScores(KEY, 0, -1);
        var out = new LinkedHashMap<String, Double>();
        if (ranked != null) {
            for (ZSetOperations.TypedTuple<String> t : ranked) {
                out.put(t.getValue(), t.getScore());
            }
        }
        return out;
    }
}
