package slice;

import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.AutoConfigurationPackage;

/**
 * Course 8, unit 18: the configuration TiffinBox's MongoDB slice starts from - test sources only, never the application's.
 *
 * <p>{@code @DataMongoTest} starts Spring Data MongoDB's part of the application: a MongoClient, the MongoTemplate and Spring Data
 * MongoDB's repositories, and leaves the web layer, the kitchen, the database and every other bean out. Like {@link RedisSlice}
 * beside it, it looks for a {@code @SpringBootConfiguration} in the test's package and every package above it, and TiffinBoxApp is
 * not one. This class names one thing: the package Spring Data MongoDB's repository and document scan starts from
 * ({@code @AutoConfigurationPackage}, this one - it holds no repository and no document). The class the test checks - Menus, a
 * {@code @RestController} the slice would not load - is imported by the test itself, and the test carries the container.
 *
 * <p>It lives outside com.tiffinbox for DataSlice's reason: there, TiffinBoxApp's own scan would find it.
 */
@SpringBootConfiguration
@AutoConfigurationPackage
public class MongoSlice {
}
