package probe.u14;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import com.tiffinbox.TiffinBoxProperties;
import com.tiffinbox.web.Leaderboard;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.cache.CacheManager;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.ValueEncoding;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;

import javax.sql.DataSource;
import java.io.InputStream;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 14's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), started as the receipt
 * says - under the profile "dev" on PostgreSQL + Redis, or the default run on H2 - and read through the context's own beans. Witness
 * 1 is Java's answer (the shipped Leaderboard's route, or a template bean of the context); witness 2 is redis-cli inside the Redis
 * container, which the receipt runs while this JVM waits at a pause (R.398). args[0] is a comma-separated list of steps; every
 * line it prints starts with PROBE:
 *   info     the database that answered, the profiles, the versions, the CacheManager bean, the Leaderboard beans, the Redis
 *            connection and its INFO server line (when one is configured), the two template beans and their serializers
 *   http     GET /dashboard, /actuator/health, /actuator/health/readiness, /leaderboard and /kitchen (java.net.http, 127.0.0.1)
 *   zset     the shipped board read by the context's StringRedisTemplate: reverseRangeWithScores, score, reverseRank, zCard, type,
 *            encoding; the scores' sum beside /kitchen's ordersValue; a pause (redis-cli reads the same key)
 *   flip     the harness's keys h14:z<n> and h14:z<n+1>, n read off CONFIG GET zset-max-listpack-entries; their encodings; a pause;
 *            the keys deleted
 *   structs  the harness's hash, set and counter (one structure each); a pause; the keys deleted
 *   twice    the shipped Leaderboard.record loop run twice with no reset between; a pause; then reset and one fill again
 *   trap     the same fill through Boot's redisTemplate bean (RedisTemplate of Object and Object) on a clean key; a pause; deleted
 *   noboard  the default run: Leaderboard beans, GET /leaderboard
 *   rename   GET /actuator/health and /dashboard at two pauses: the receipt renames the customer table between them (#119)
 *   hold     a pause the receipt answers with SIGINT (the JVM's exit is 130)
 * Harness keys start h14: and are deleted by the step that wrote them; nothing here writes the shipped key but twice and trap,
 * each labelled, each leaving the board as the start left it or deleted.
 */
public final class U14 {
    private U14() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static String port = "";
    static String who = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        try {
            ctx = app.run(rest);
        } catch (Throwable t) {
            System.out.println("PROBE started: no · " + t.getClass().getName());
            System.out.println("PROBE <<< exit 1");
            System.exit(1);
        }
        int code = 0;
        try {
            db = product(ctx.getBean(DataSource.class));
            port = ctx.getEnvironment().getProperty("local.server.port");
            String[] prof = ctx.getEnvironment().getActiveProfiles();
            who = (prof.length == 0 ? "default run" : "profile " + String.join(",", prof)) + ", " + db;
            p("started: yes · " + who + " · a web server: " + (port != null ? "yes" : "no"));
            for (String s : steps.split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            p("a step threw: " + t.getClass().getName() + ": " + first(t.getMessage()));
        }
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
    }

    static String first(String m) {
        if (m == null) return "null";
        String s = m.split("\n")[0];
        return s.length() > 240 ? s.substring(0, 240) + "…" : s;
    }

    static String product(DataSource ds) throws Exception {
        try (var c = ds.getConnection()) {
            var md = c.getMetaData();
            return md.getDatabaseProductName() + " " + md.getDatabaseProductVersion().split(" ")[0];
        }
    }

    static String jarVersion(Class<?> c) {
        return c.getPackage().getImplementationVersion();
    }

    static String last = "";

    static String get(String path) throws Exception {
        var c = HttpClient.newBuilder().proxy(HttpClient.Builder.NO_PROXY).build();
        var r = c.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        last = r.body();
        return String.valueOf(r.statusCode());
    }

    static StringRedisTemplate strings() {
        return ctx.getBean(StringRedisTemplate.class);
    }

    static String encoding(String key) {
        try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            ValueEncoding e = conn.keyCommands().encodingOf(key.getBytes(StandardCharsets.UTF_8));
            return e == null ? "null" : e.raw();
        }
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "info" -> info();
            case "http" -> http();
            case "zset" -> zset();
            case "flip" -> flip();
            case "structs" -> structs();
            case "twice" -> twice();
            case "trap" -> trap();
            case "noboard" -> noboard();
            case "rename" -> rename();
            case "hold" -> hold();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt runs redis-cli or psql while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U14.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Redis " + jarVersion(RedisTemplate.class)
                + " · Lettuce " + jarVersion(io.lettuce.core.RedisClient.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var desc = new ArrayList<String>();
        ctx.getBeansOfType(CacheManager.class).forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + desc.size() + " " + desc + " (" + who + ")");
        Map<String, Leaderboard> boards = ctx.getBeansOfType(Leaderboard.class);
        var bd = new ArrayList<String>();
        boards.forEach((k, v) -> bd.add(k + "=" + v.getClass().getName()));
        p("Leaderboard beans " + boards.size() + " " + bd + " (" + who + ")");
        if ("dev".equals(String.join(",", ctx.getEnvironment().getActiveProfiles()))) {
            var cf = ctx.getBean(RedisConnectionFactory.class);
            var lf = (org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory) cf;
            p("RedisConnectionFactory: " + cf.getClass().getName() + " · the connection: " + lf.getHostName() + ":" + lf.getPort());
            try (var conn = cf.getConnection()) {
                p("Redis's INFO server, through the connection: redis_version:" + conn.serverCommands().info("server").getProperty("redis_version"));
            }
        }
        Map<String, RedisTemplate> ts = ctx.getBeansOfType(RedisTemplate.class);
        for (String name : new TreeSet<>(ts.keySet())) {
            RedisTemplate<?, ?> t = ts.get(name);
            p("the template bean " + name + ": " + t.getClass().getName() + " · key serializer " + cls(t.getKeySerializer())
                    + " · value serializer " + cls(t.getValueSerializer()));
        }
    }

    static String cls(Object o) {
        return o == null ? "null" : o.getClass().getName();
    }

    static void http() throws Exception {
        for (String path : List.of("/dashboard", "/actuator/health", "/actuator/health/readiness", "/leaderboard", "/kitchen")) {
            String code = get(path);
            String extra = "";
            if (path.startsWith("/actuator/health")) {
                Matcher top = Pattern.compile("\"status\":\"([A-Z_]+)\"\\}$").matcher(last.trim());
                extra = " · status " + (top.find() ? top.group(1) : "?");
            } else if (path.equals("/leaderboard") && code.equals("200")) {
                extra = " · " + last.trim();
            } else if (path.equals("/kitchen")) {
                Matcher v = Pattern.compile("\"ordersValue\":(\\d+)").matcher(last);
                Matcher c = Pattern.compile("\"ordersCooked\":(\\d+)").matcher(last);
                extra = " · ordersCooked " + (c.find() ? c.group(1) : "?") + " · ordersValue " + (v.find() ? v.group(1) : "?");
            }
            p("http (" + who + "): GET " + path + " -> " + code + extra);
        }
    }

    static final String KEY = "tiffinbox:leaderboard";

    static String scores(Set<ZSetOperations.TypedTuple<String>> ranked) {
        var out = new ArrayList<String>();
        for (var t : ranked) out.add(t.getValue() + " " + Math.round(t.getScore()));
        return String.join(" · ", out);
    }

    static void zset() throws Exception {
        var z = strings().opsForZSet();
        var ranked = z.reverseRangeWithScores(KEY, 0, -1);
        long sum = 0;
        for (var t : ranked) sum += Math.round(t.getScore());
        p("zset (" + who + ", the context's StringRedisTemplate): reverseRangeWithScores(" + KEY + ", 0, -1) -> " + scores(ranked));
        p("zset: score(Ravi) " + z.score(KEY, "Ravi") + " · reverseRank(Sunil) " + z.reverseRank(KEY, "Sunil") + " · zCard " + z.zCard(KEY)
                + " · type " + strings().type(KEY).code() + " · encoding " + encoding(KEY));
        get("/kitchen");
        Matcher v = Pattern.compile("\"ordersValue\":(\\d+)").matcher(last);
        p("zset: the four scores' sum " + sum + " · /kitchen's ordersValue " + (v.find() ? v.group(1) : "?"));
        pause();
    }

    static void flip() throws Exception {
        var t = strings();
        String n;
        try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
            n = conn.serverCommands().getConfig("zset-max-listpack-entries").getProperty("zset-max-listpack-entries");
        }
        p("flip (a harness's keys, not the anchor's board; " + who + "): CONFIG GET zset-max-listpack-entries, through the connection -> " + n);
        int max = Integer.parseInt(n);
        for (int size : new int[] {max, max + 1}) {
            String k = "h14:z" + size;
            var tuples = new java.util.LinkedHashSet<ZSetOperations.TypedTuple<String>>();
            for (int i = 1; i <= size; i++) tuples.add(ZSetOperations.TypedTuple.of("m" + i, (double) i));
            t.opsForZSet().add(k, tuples);
            p("flip: " + k + " · zCard " + t.opsForZSet().zCard(k) + " · type " + t.type(k).code() + " · encoding " + encoding(k));
        }
        pause();
        p("flip: deleted " + t.delete(List.of("h14:z" + max, "h14:z" + (max + 1))) + " harness keys");
    }

    static void structs() throws Exception {
        var t = strings();
        Customer ravi = ctx.getBean(CustomerRepository.class).findByName("Ravi").orElseThrow();
        var fields = new LinkedHashMap<String, String>();
        fields.put("mealType", ravi.mealType());
        fields.put("pricePerMeal", String.valueOf(ravi.pricePerMeal()));
        fields.put("mealsPerDay", String.valueOf(ravi.mealsPerDay()));
        String h = "h14:customer:Ravi", s = "h14:meal-types", c = "h14:orders-placed";
        t.opsForHash().putAll(h, fields);
        p("structs (a harness's keys, not the anchor's; " + who + "): a hash from the seed's row, HSET " + h + " (a LinkedHashMap) -> entries "
                + t.opsForHash().entries(h) + " · type " + t.type(h).code() + " · encoding " + encoding(h));
        var types = new ArrayList<String>();
        ctx.getBean(TiffinBoxProperties.class).mealTypes().forEach(m -> types.add(m.name()));
        t.opsForSet().add(s, types.toArray(new String[0]));
        p("structs: the meal types' set (tiffinbox.meal-types), SADD " + s + " -> members, sorted " + new TreeSet<>(t.opsForSet().members(s))
                + " · type " + t.type(s).code() + " · encoding " + encoding(s));
        p("structs: a counter, INCR " + c + " -> " + t.opsForValue().increment(c) + " · type " + t.type(c).code() + " · encoding " + encoding(c));
        pause();
        p("structs: deleted " + t.delete(List.of(h, s, c)) + " harness keys");
    }

    /** The start's own orders, as TiffinBoxServer places them: each customer, tiffinbox.days times, meals times price. */
    interface Fill {
        void add(String customer, double value);
    }

    static int fill(Fill f) throws Exception {
        int n = 0;
        int days = ctx.getBean(TiffinBoxProperties.class).days();
        for (Customer c : ctx.getBean(CustomerRepository.class).findAll()) {
            for (int d = 0; d < days; d++) {
                f.add(c.name(), c.mealsPerDay() * c.pricePerMeal());
                n++;
            }
        }
        return n;
    }

    static void twice() throws Exception {
        Leaderboard lb = ctx.getBean(Leaderboard.class);
        var z = strings().opsForZSet();
        p("twice (the harness calls the shipped Leaderboard.record, not the start; " + who + "): the board the start left -> " + scores(z.reverseRangeWithScores(KEY, 0, -1)));
        lb.reset();
        p("twice: reset() first, so the harness's two fills start from an empty key -> zCard " + z.zCard(KEY));
        int a = fill(lb::record);
        int b = fill(lb::record);
        p("twice: two fills, " + a + " and " + b + " record calls, no reset between -> " + scores(z.reverseRangeWithScores(KEY, 0, -1)));
        pause();
        lb.reset();
        int c = fill(lb::record);
        p("twice: then reset() and one fill (" + c + " record calls), the start's own shape -> " + scores(z.reverseRangeWithScores(KEY, 0, -1)));
    }

    @SuppressWarnings("unchecked")
    static void trap() throws Exception {
        RedisTemplate<Object, Object> rt = (RedisTemplate<Object, Object>) ctx.getBean("redisTemplate");
        p("trap (a harness's fill through Boot's redisTemplate bean, not the anchor's Leaderboard; " + who + "): " + rt.getClass().getName()
                + " · key serializer " + cls(rt.getKeySerializer()) + " · value serializer " + cls(rt.getValueSerializer()));
        p("trap: the start's board deleted first through StringRedisTemplate, so the plain key is clean: delete -> " + strings().delete(KEY));
        int n = fill((name, value) -> rt.opsForZSet().incrementScore(KEY, name, value));
        p("trap: " + n + " incrementScore calls through redisTemplate, each returned without an exception");
        p("trap: StringRedisTemplate on the plain key: hasKey " + strings().hasKey(KEY) + " · score(Ravi) " + strings().opsForZSet().score(KEY, "Ravi"));
        p("trap: redisTemplate on its own key: hasKey " + rt.hasKey(KEY) + " · score(Ravi) " + rt.opsForZSet().score(KEY, "Ravi") + " · zCard " + rt.opsForZSet().zCard(KEY));
        pause();
        p("trap: redisTemplate.delete -> " + rt.delete(KEY));
    }

    static void noboard() throws Exception {
        p("noboard (" + who + "): getBeansOfType(Leaderboard) " + ctx.getBeansOfType(Leaderboard.class).size() + " · GET /leaderboard -> " + get("/leaderboard"));
    }

    static void rename() throws Exception {
        // first a request that reads the customer list, so the cache holds it; then the receipt renames the table (pause 1),
        // empties Redis (pause 2) and renames the table back (pause 3), the routes read after each
        String h = get("/actuator/health");
        p("rename (" + who + "), before the receipt's first pause, a request that reads the list (the cache then holds it): GET /actuator/health -> " + h);
        for (int k = 1; k <= 3; k++) {
            pause();
            var out = new ArrayList<String>();
            for (String path : List.of("/actuator/health", "/actuator/health/readiness", "/dashboard", "/customers")) {
                String code = get(path);
                if (path.startsWith("/actuator/health")) {
                    Matcher top = Pattern.compile("\"status\":\"([A-Z_]+)\"\\}$").matcher(last.trim());
                    code += " " + (top.find() ? top.group(1) : "?");
                }
                out.add("GET " + path + " -> " + code);
            }
            p("rename (" + who + "), after the receipt's pause " + pauses + ": " + String.join(" · ", out));
        }
    }

    static void hold() throws Exception {
        // the receipt answers this pause with SIGINT, never with ./go: the JVM waits here, polling nothing, until the signal ends it
        p("hold (" + who + "): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        p("hold: no SIGINT came");
    }
}
