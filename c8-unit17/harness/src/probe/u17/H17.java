package probe.u17;

import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * Unit 17's Redis harness: the lock, holders A, B and C, Redlock's majority and the counter - the HARNESS's, never TiffinBox's (⚑8:
 * TiffinBox ships no lock and no counter). Lettuce's connection factory on 127.0.0.1 and a StringRedisTemplate per Redis, nothing
 * else - no TiffinBox start, no web server, no database. The lock is one key, tiffinbox:lock:kitchen-slot, its value the holder's
 * name; its time to live is LOCK_TTL below (a constant of the harness, never printed - the captures say "the lock's time to live").
 * args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   acq=N      holder N: SET the key to N if absent, with the lock's time to live (setIfAbsent) - acquired true/false
 *   pause      the receipt reads now (redis-cli), then writes ./go
 *   past       the planted hold: the harness holds this holder past its lock's time to live - a pause polling ./go on a count (the
 *              receipt answers it once its EXISTS poll reads 0 and B has acquired)
 *   see=N      holder N reads the key's value before its release (GET)
 *   del=N      holder N releases by DEL - deleted true/false
 *   lua=N      holder N releases by the Lua compare-and-delete (DEL only if the value is still N) - returned 1/0
 *   redlock=N  the harness's majority acquire on every port of -Dh17.ports: SET NX with the lock's time to live on each, the list per
 *              instance, "k of 3 -> HELD / NOT HELD" (majority 2); after NOT HELD the minority release - the Lua compare-and-delete
 *              on each instance it got. A sketch: no clock-drift term, no retry
 *   rate=K     K requests through the counter: one Lua script INCRs tiffinbox:rate:kitchen-slot and sets its time to live on the
 *              first (RATE_TTL, never printed); limit 5 - allowed / refused
 *   race       INCR tiffinbox:rate:race, then the planted hold before its EXPIRE: a pause the receipt answers with SIGINT (exit 130)
 */
public final class H17 {
    private H17() {}

    static final String LOCK = "tiffinbox:lock:kitchen-slot";
    static final String RATE = "tiffinbox:rate:kitchen-slot";
    static final String RACE = "tiffinbox:rate:race";
    static final Duration LOCK_TTL = Duration.ofMillis(3000);
    static final String RATE_TTL = "60";
    static final int LIMIT = 5;
    static final DefaultRedisScript<Long> RELEASE = new DefaultRedisScript<>(
            "if redis.call('GET', KEYS[1]) == ARGV[1] then return redis.call('DEL', KEYS[1]) else return 0 end", Long.class);
    static final DefaultRedisScript<Long> COUNT = new DefaultRedisScript<>(
            "local c = redis.call('INCR', KEYS[1]); if c == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end; return c", Long.class);
    static final List<LettuceConnectionFactory> factories = new ArrayList<>();
    static StringRedisTemplate t;

    static StringRedisTemplate template(int port) {
        var f = new LettuceConnectionFactory(new RedisStandaloneConfiguration("127.0.0.1", port));
        f.afterPropertiesSet();
        f.start();
        factories.add(f);
        var s = new StringRedisTemplate(f);
        s.afterPropertiesSet();
        return s;
    }

    public static void main(String[] args) throws Exception {
        // Logback's default layout (every exception's class and stack printed), the root at WARN: an ERROR is never hidden (R.410)
        ((ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("ROOT")).setLevel(ch.qos.logback.classic.Level.WARN);
        int code = 0;
        try {
            t = template(Integer.getInteger("h17.port"));
            for (String s : args[0].split(",")) step(s);
        } catch (Throwable x) {
            code = 1;
            p("a step threw: " + x.getClass().getName() + ": " + first(x.getMessage()));
        }
        for (var f : factories) f.destroy();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
        System.out.flush();
    }

    static String first(String m) {
        if (m == null) return "null";
        String s = m.split("\n")[0];
        return s.length() > 240 ? s.substring(0, 240) + "…" : s;
    }

    static void step(String s) throws Exception {
        int e = s.indexOf('=');
        String k = e < 0 ? s : s.substring(0, e), v = e < 0 ? "" : s.substring(e + 1);
        switch (k) {
            case "acq" -> p("holder " + v + " (the harness's lock): setIfAbsent(" + LOCK + ", " + v + ", <the lock's time to live>) -> acquired " + t.opsForValue().setIfAbsent(LOCK, v, LOCK_TTL));
            case "pause" -> pause();
            case "past" -> { p("the harness holds this holder past its lock's time to live (planted, labelled)"); pause(); }
            case "see" -> {
                String g = t.opsForValue().get(LOCK);
                p("holder " + v + " sees the lock's value before release: " + (g == null ? "(nil)" : g));
                if (g != null && !g.equals(v)) p("holder " + v + " and holder " + g + " held at once: " + v + "'s work ran past its lock while " + g + " held it (the planted hold)");
            }
            case "del" -> p("holder " + v + " releases by DEL (the harness's lock): deleted " + t.delete(LOCK));
            case "lua" -> p("holder " + v + " releases by the Lua compare-and-delete (the harness's lock): returned " + t.execute(RELEASE, List.of(LOCK), v));
            case "redlock" -> redlock(v);
            case "rate" -> rate(Integer.parseInt(v));
            case "race" -> race();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt runs redis-cli while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static void redlock(String name) {
        var got = new ArrayList<StringRedisTemplate>();
        var list = new ArrayList<String>();
        var gotPorts = new ArrayList<Integer>();
        String[] ports = System.getProperty("h17.ports").split(",");
        for (String ps : ports) {
            int port = Integer.parseInt(ps);
            var s = template(port);
            try {
                Boolean ok = s.opsForValue().setIfAbsent(LOCK, name, LOCK_TTL);
                list.add(port + " -> " + ok);
                if (Boolean.TRUE.equals(ok)) { got.add(s); gotPorts.add(port); }
            } catch (RuntimeException x) {
                list.add(port + " -> " + x.getClass().getSimpleName());
            }
        }
        int maj = ports.length / 2 + 1;
        boolean held = got.size() >= maj;
        p("redlock (the harness's majority acquire, holder " + name + "): " + String.join(" · ", list));
        p("redlock: " + got.size() + " of " + ports.length + " -> " + (held ? "HELD" : "NOT HELD") + " (majority " + maj + ")");
        if (!held) for (int i = 0; i < got.size(); i++)
            p("redlock: the minority release on " + gotPorts.get(i) + " (the Lua compare-and-delete) -> returned " + got.get(i).execute(RELEASE, List.of(LOCK), name));
    }

    static void rate(int n) {
        for (int i = 1; i <= n; i++) {
            Long c = t.execute(COUNT, List.of(RATE), RATE_TTL);
            p("request " + i + " (the harness's counter, the Lua INCR + EXPIRE on the first): count " + c + " -> " + (c <= LIMIT ? "allowed" : "refused") + " (limit " + LIMIT + ")");
        }
    }

    static void race() throws Exception {
        p("the harness's counter, INCR " + RACE + " -> " + t.opsForValue().increment(RACE));
        p("the harness holds before its EXPIRE (planted, labelled): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        t.expire(RACE, Duration.ofSeconds(Long.parseLong(RATE_TTL)));
        p("race: no SIGINT came");
    }
}
