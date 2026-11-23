package slice;

import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.AutoConfigurationPackage;

/**
 * Course 8, unit 14: the configuration TiffinBox's Redis slice starts from - test sources only, never the application's.
 *
 * <p>{@code @DataRedisTest} starts Spring Data Redis's part of the application: a Redis connection factory (Lettuce's), the two
 * template beans - redisTemplate and stringRedisTemplate - and Spring Data Redis's repositories, and leaves the web layer, the
 * kitchen, the database and every other bean out. Like {@link DataSlice} and {@link JdbcSlice} beside it, it looks for a
 * {@code @SpringBootConfiguration} in the test's package and every package above it, and TiffinBoxApp is not one. This class names
 * one thing: the package Spring Data Redis's repository scan starts from ({@code @AutoConfigurationPackage}, this one - it holds
 * no repository). Without it the slice's start stops (Unable to retrieve @EnableAutoConfiguration base packages). The class the
 * test checks - Leaderboard, a {@code @RestController} the slice would not load - is imported by the test itself.
 *
 * <p>It lives outside com.tiffinbox for DataSlice's reason: there, TiffinBoxApp's own scan would find it.
 *
 * <p>Course 8, unit 15: the slice starts none of Spring Data Redis's repositories since - application.yaml, which the slice reads,
 * switches Boot's own off (spring.data.redis.repositories.enabled: false). The repository TiffinBox ships, KitchenOrders, is
 * registered by RedisDatastore, which RedisDatastoreIT imports under the profile "dev".
 */
@SpringBootConfiguration
@AutoConfigurationPackage
public class RedisSlice {
}
