import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;

import java.time.Duration;
import java.util.List;

/**
 * The exercise of c8-unit17 (Course 8): a lock in Redis, one key, tiffinbox:lock:kitchen-slot, whose value is its holder's name.
 * Holder A takes it with a time to live (SET NX with a time to live - setIfAbsent). Then this program holds A past its lock's time
 * to live on purpose: it reads EXISTS until the key is gone (a count, capped) - A "outlived" its lock. Holder B takes the lock. Then
 * A releases: with "del" by DEL, whatever the key holds now; with "lua" by a Lua script that deletes the key only if its value is
 * still A. Run: java Release PORT del|lua. Lettuce's connection factory and Spring Data Redis's StringRedisTemplate, built here - no
 * Spring context, no TiffinBox, no database. The check is redis-cli's GET afterwards, never this program's exit.
 */
public class Release {
    static final String LOCK = "tiffinbox:lock:kitchen-slot";
    static final Duration TTL = Duration.ofMillis(3000);

    public static void main(String[] args) throws Exception {
        ((ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("ROOT")).setLevel(ch.qos.logback.classic.Level.WARN);
        var f = new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.parseInt(args[0])));
        f.afterPropertiesSet();
        f.start();
        var t = new StringRedisTemplate(f);
        t.afterPropertiesSet();
        t.delete(LOCK);
        System.out.println("holder A: acquired " + t.opsForValue().setIfAbsent(LOCK, "A", TTL));
        int i = 0;
        while (Boolean.TRUE.equals(t.hasKey(LOCK)) && i < 3000) { Thread.sleep(10); i++; }
        System.out.println("the program holds A past its lock's time to live (EXISTS read until 0): EXISTS " + (Boolean.TRUE.equals(t.hasKey(LOCK)) ? 1 : 0));
        System.out.println("holder B: acquired " + t.opsForValue().setIfAbsent(LOCK, "B", TTL));
        System.out.println("holder A sees, before its release: " + t.opsForValue().get(LOCK));
        if (args[1].equals("lua")) {
            var release = new DefaultRedisScript<>("if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end", Long.class);
            System.out.println("holder A releases by the Lua compare-and-delete: returned " + t.execute(release, List.of(LOCK), "A"));
        } else {
            System.out.println("holder A releases by DEL: deleted " + t.delete(LOCK));
        }
        f.destroy();
    }
}
