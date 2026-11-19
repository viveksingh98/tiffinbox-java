import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 14's exercise: the kitchen's leaderboard written to Redis from Java, with no TiffinBox and no database - a standalone
 * program on the anchor's libraries. It reads the four customers from the anchor's seed (V2__seed.sql) and the days the kitchen
 * cooks for (application.yaml's tiffinbox.days), deletes tiffinbox:leaderboard, and adds every order's value - meals times price,
 * once per day - to its customer's score with ZINCRBY, as TiffinBoxServer.start() does under the profile "dev". The template it
 * writes through is the one line to change. args: the seed file, the YAML file, Redis's port on 127.0.0.1.
 */
public class Board {
    static final String KEY = "tiffinbox:leaderboard";

    public static void main(String[] args) throws Exception {
        String seed = Files.readString(Path.of(args[0]));
        Matcher dm = Pattern.compile("(?m)^  days: (\\d+)$").matcher(Files.readString(Path.of(args[1])));
        if (!dm.find()) throw new IllegalStateException("no tiffinbox.days in " + args[1]);
        int days = Integer.parseInt(dm.group(1));
        var cf = new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", Integer.parseInt(args[2])));
        cf.afterPropertiesSet();
        cf.start();
        var board = new RedisTemplate<Object, Object>();
        board.setConnectionFactory(cf);
        board.afterPropertiesSet();
        System.out.println("template: " + board.getClass().getSimpleName() + " · key serializer " + board.getKeySerializer().getClass().getSimpleName());
        board.delete(KEY);
        int orders = 0;
        Matcher m = Pattern.compile("VALUES \\('([A-Za-z]+)', (\\d+), (\\d+), '[A-Z_]+'\\)").matcher(seed);
        while (m.find()) {
            for (int d = 0; d < days; d++) {
                board.opsForZSet().incrementScore(KEY, m.group(1), Integer.parseInt(m.group(2)) * Integer.parseInt(m.group(3)));
                orders++;
            }
        }
        System.out.println("orders written: " + orders + " · no exception");
        cf.destroy();
    }
}
