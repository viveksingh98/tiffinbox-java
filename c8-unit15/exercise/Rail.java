import com.tiffinbox.web.KitchenOrder;
import com.tiffinbox.web.KitchenOrders;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisKeyValueAdapter.EnableKeyspaceEvents;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 15's exercise: the kitchen's orders on Redis through the anchor's own KitchenOrder and KitchenOrders, with no TiffinBox and
 * no database - a small Spring context of its own on the anchor's libraries. It saves three orders, the anchor's seed giving each
 * value (meals times price): o1 (Ravi) and o2 (Sunil) with a time to live - TTL below, a configured number - and o3 (Meera) with
 * none. Then it stays up: it reads redis-cli's question from Java until both timed hashes are gone, reads SCARD kitchen-order until
 * it holds the untimed order alone or a cap of reads is reached, and prints what the repository says. The repository configuration
 * it runs on is the one line to change (RailConfig's @EnableRedisRepositories). args: the seed file, Redis's port on 127.0.0.1.
 */
public class Rail {
    /** The two timed orders' time to live: the program's own setting, never printed. */
    static final long TTL = 2;

    public static void main(String[] args) throws Exception {
        ((ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("ROOT")).setLevel(ch.qos.logback.classic.Level.WARN);
        System.setProperty("rail.port", args[1]);
        var ctx = new AnnotationConfigApplicationContext(RailConfig.class);
        var orders = ctx.getBean(KitchenOrders.class);
        var strings = ctx.getBean(StringRedisTemplate.class);
        try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            System.out.println("keyspace events (CONFIG GET notify-keyspace-events): \"" + conn.serverCommands().getConfig("notify-keyspace-events").getProperty("notify-keyspace-events") + "\"");
        }
        String seed = Files.readString(Path.of(args[0]));
        Matcher m = Pattern.compile("VALUES \\('([A-Za-z]+)', (\\d+), (\\d+), '([A-Z_]+)'\\)").matcher(seed);
        var value = new java.util.HashMap<String, Integer>();
        while (m.find()) value.put(m.group(1), Integer.parseInt(m.group(2)) * Integer.parseInt(m.group(3)));
        orders.save(new KitchenOrder("o1", "Ravi", "VEG", value.get("Ravi"), TTL));
        orders.save(new KitchenOrder("o2", "Sunil", "VEG", value.get("Sunil"), TTL));
        orders.save(new KitchenOrder("o3", "Meera", "NON_VEG", value.get("Meera"), null));
        System.out.println("orders saved: 3 (o1 and o2 with a time to live, o3 with none) · count() " + orders.count());
        int i = 0;
        while (Boolean.TRUE.equals(strings.hasKey("kitchen-order:o1")) || Boolean.TRUE.equals(strings.hasKey("kitchen-order:o2"))) {
            if (++i > 300) throw new IllegalStateException("the timed hashes are still there after 300 reads");
            Thread.sleep(100);
        }
        System.out.println("the timed hashes gone (EXISTS kitchen-order:o1, kitchen-order:o2: 0), the JVM still up");
        int j = 0;
        while (strings.opsForSet().size("kitchen-order") != 1 && j < 50) {
            j++;
            Thread.sleep(100);
        }
        System.out.println("SCARD kitchen-order, read until it holds the untimed order alone (a cap of 50 reads): "
                + (strings.opsForSet().size("kitchen-order") == 1 ? "reached" : "not reached") + ", " + strings.opsForSet().size("kitchen-order"));
        var all = new ArrayList<KitchenOrder>();
        orders.findAll().forEach(all::add);
        System.out.println("count(): " + orders.count());
        System.out.println("findAll(): " + all);
        ctx.close();
    }
}

@Configuration(proxyBeanMethods = false)
@EnableRedisRepositories(basePackageClasses = KitchenOrders.class)
class RailConfig {
    @Bean
    LettuceConnectionFactory redisConnectionFactory() {
        return new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.getInteger("rail.port")));
    }

    @Bean
    RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory cf) {
        var t = new RedisTemplate<Object, Object>();
        t.setConnectionFactory(cf);
        return t;
    }

    @Bean
    StringRedisTemplate stringRedisTemplate(RedisConnectionFactory cf) {
        return new StringRedisTemplate(cf);
    }

    /** Names the enum the solution's line uses, so the file compiles the same in both states. */
    static final EnableKeyspaceEvents OFF_IS_THE_DEFAULT = EnableKeyspaceEvents.OFF;
}
