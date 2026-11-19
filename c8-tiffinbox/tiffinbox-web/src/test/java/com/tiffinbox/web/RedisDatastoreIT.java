package com.tiffinbox.web;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.redis.test.autoconfigure.DataRedisTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;
import slice.RedisSlice;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

/**
 * Course 8, unit 14: the leaderboard TiffinBox ships, on Redis in a container. {@code @DataRedisTest} starts Spring Data Redis's
 * slice (slice/RedisSlice): the connection factory and the two templates, no web layer - so the test imports Leaderboard itself, a
 * {@code @RestController} the slice would leave out, under the profile it carries, "dev". The container is the image the course
 * pinned, by its digest; Boot's service connection (name "redis") hands the slice its address. Boot's Docker Compose support does
 * not start in a test. Run by mvn verify only (the container-tests execution, tiffinbox-web/pom.xml).
 *
 * <p>Two witnesses in one test: the shipped bean writes the four customers' values and reads the board back (ZREVRANGE ...
 * WITHSCORES), and the slice's own StringRedisTemplate reads the same key - its type, a score and a rank.
 *
 * <p>Course 8, unit 15: and the kitchen's orders, KitchenOrders - the repository TiffinBox ships. application.yaml switches Boot's
 * own Redis repositories off (spring.data.redis.repositories.enabled: false), and the slice reads that file: the test imports
 * RedisDatastore, the configuration that registers KitchenOrders under "dev", the profile this class already carries. Its
 * listener (keyspace events ON_STARTUP) writes notify-keyspace-events on the container's Redis with CONFIG SET; the container is
 * removed after the run. Two witnesses again: the repository saves three orders and answers findByMealType and count(), and the
 * slice's StringRedisTemplate reads the index set and the hash's type.
 */
@DataRedisTest
@ContextConfiguration(classes = RedisSlice.class)
@Import({Leaderboard.class, RedisDatastore.class})
@ActiveProfiles("dev")
@Testcontainers
class RedisDatastoreIT {

    @Container
    @ServiceConnection(name = "redis")
    static GenericContainer<?> redis = new GenericContainer<>(
            DockerImageName.parse("redis@sha256:7958cfbb9d152f87dadfbc89f1b0b15938f0b81ff8982feb327476f4911935c3").asCompatibleSubstituteFor("redis"))
            .withExposedPorts(6379);

    @Autowired Leaderboard board;
    @Autowired StringRedisTemplate strings;
    @Autowired KitchenOrders orders;

    @Test
    void theLeaderboardIsASortedSetRedisReadsByName() {
        board.reset();
        board.record("Ravi", 7200);
        board.record("Meera", 4500);
        board.record("Sunil", 9000);
        board.record("Priya", 3600);
        var ranked = new ArrayList<String>(board.board().keySet());
        System.out.println("REDIS IT the board, through Leaderboard: " + board.board());
        List<String> direct = new ArrayList<>();
        for (ZSetOperations.TypedTuple<String> t : strings.opsForZSet().reverseRangeWithScores(Leaderboard.KEY, 0, -1)) {
            direct.add(t.getValue());
        }
        System.out.println("REDIS IT the same key, through the slice's StringRedisTemplate: type " + strings.type(Leaderboard.KEY).code()
                + " · score(Ravi) " + strings.opsForZSet().score(Leaderboard.KEY, "Ravi") + " · reverseRank(Sunil) "
                + strings.opsForZSet().reverseRank(Leaderboard.KEY, "Sunil") + " · order " + direct);
        assertThat(ranked).containsExactly("Sunil", "Ravi", "Meera", "Priya");
        assertThat(direct).isEqualTo(ranked);
        assertThat(strings.type(Leaderboard.KEY).code()).isEqualTo("zset");
        assertThat(strings.opsForZSet().score(Leaderboard.KEY, "Ravi")).isEqualTo(7200.0);
        assertThat(strings.opsForZSet().reverseRank(Leaderboard.KEY, "Sunil")).isZero();
    }

    @Test
    void theKitchenOrdersAreHashesAndTheirIndexSetsRedisReadsByName() {
        orders.deleteAll();
        // two orders with a time to live (a whole number, as EXPIRE takes it - long enough to outlast the test), one with none
        orders.save(new KitchenOrder("Ravi-1", "Ravi", "VEG", 240, 600L));
        orders.save(new KitchenOrder("Sunil-1", "Sunil", "VEG", 300, 600L));
        orders.save(new KitchenOrder("Meera-1", "Meera", "NON_VEG", 150, null));
        var veg = new TreeSet<String>();
        orders.findByMealType("VEG").forEach(o -> veg.add(o.getId()));
        var vegSet = new TreeSet<String>(strings.opsForSet().members("kitchen-order:mealType:VEG"));
        System.out.println("REDIS IT the orders, through KitchenOrders: count() " + orders.count() + " · findByMealType(VEG) " + veg);
        System.out.println("REDIS IT the same keys, through the slice's StringRedisTemplate: SMEMBERS kitchen-order:mealType:VEG " + vegSet
                + " · SCARD kitchen-order " + strings.opsForSet().size("kitchen-order") + " · type kitchen-order:Ravi-1 "
                + strings.type("kitchen-order:Ravi-1").code());
        assertThat(veg).containsExactly("Ravi-1", "Sunil-1");
        assertThat(vegSet).isEqualTo(veg);
        assertThat(orders.count()).isEqualTo(3);
        assertThat(strings.opsForSet().size("kitchen-order")).isEqualTo(3);
        assertThat(strings.type("kitchen-order:Ravi-1").code()).isEqualTo("hash");
        orders.deleteAll();
    }
}
