package probe.u17;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.cache.CacheManager;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;

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
import java.util.List;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicReference;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 17's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port) and Counter (unit 13's
 * invocation counter: the calls that reach Spring Data JPA's repository for CustomerEntity, witness 1), started as the receipt says -
 * under the profile "dev" on PostgreSQL + Redis, or the default run on H2. Nothing here writes to Redis but the anchor's own beans:
 * the go key tiffinbox:u17:go is written by the receipt (redis-cli), and this JVM only reads it. args[0] is a comma-separated list of
 * steps; every line it prints starts with PROBE:
 *   info     the database, the profiles, the versions, the cache's store, the Redis connection's INFO server line (under "dev")
 *   http     GET /dashboard, /actuator/health, /leaderboard, /kitchen (java.net.http, 127.0.0.1)
 *   sync=N   JVM N of two: a pause (the receipt empties Redis and reads it), then the harness polls the Redis key tiffinbox:u17:go
 *            through the context's StringRedisTemplate until it reads 1 (a count, cap 6000 reads); then ONE call of the anchor's
 *            CustomerRepository.findAll() through the context's bean, on a thread named u17-caller. Under -Du17.hold=FILE the tree is
 *            a labelled copy whose findAll first polls FILE on that thread (the harness holds - planted): this JVM then reads its
 *            caller's state until the caller is either inside that hold or waiting inside Spring Data Redis's cache writer, the
 *            same answer STABLE reads in a row, and prints which (a count, cap 12000 reads). Then the counter's delta over the call and the list's size; then a pause.
 *   hold     a pause the receipt answers with SIGINT (the JVM's exit is 130)
 */
public final class U17 {
    private U17() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static String port = "";
    static String who = "";
    static final String GO = "tiffinbox:u17:go";
    static final int STABLE = 200;

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class);
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
            CacheManager m = ctx.getBean(CacheManager.class);
            String store = m instanceof RedisCacheManager ? "Redis" : "in the JVM, " + m.getClass().getSimpleName();
            p("started: yes · " + who + " · the cache's store: " + store + " · a web server: " + (port != null ? "yes" : "no"));
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
        System.out.flush();
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
    static HttpClient http = HttpClient.newBuilder().proxy(HttpClient.Builder.NO_PROXY).build();

    static String get(String path) throws Exception {
        var r = http.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        last = r.body();
        return String.valueOf(r.statusCode());
    }

    static void step(String s) throws Exception {
        if (s.startsWith("sync=")) { sync(s.substring(5)); return; }
        switch (s) {
            case "info" -> info();
            case "http" -> http();
            case "hold" -> hold();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt runs redis-cli and psql while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U17.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Redis " + jarVersion(RedisTemplate.class)
                + " · Lettuce " + jarVersion(io.lettuce.core.RedisClient.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        for (String b : List.of("kitchenEvents", "leaderboard", "redisDatastore"))
            p("bean " + b + ": " + (ctx.containsBean(b) ? "present" : "absent") + " (" + who + ")");
        if ("dev".equals(String.join(",", ctx.getEnvironment().getActiveProfiles()))) {
            try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
                p("Redis's INFO server, through the connection: redis_version:" + conn.serverCommands().info("server").getProperty("redis_version"));
            }
        }
    }

    static void http() throws Exception {
        for (String path : List.of("/dashboard", "/actuator/health", "/leaderboard", "/kitchen")) {
            String code = get(path);
            String extra = "";
            if (path.startsWith("/actuator/health")) {
                Matcher top = Pattern.compile("\"status\":\"([A-Z_]+)\"\\}$").matcher(last.trim());
                extra = " · status " + (top.find() ? top.group(1) : "?");
            } else if (path.equals("/kitchen")) {
                Matcher c = Pattern.compile("\"ordersCooked\":(\\d+)").matcher(last);
                extra = " · ordersCooked " + (c.find() ? c.group(1) : "?");
            }
            p("http (" + who + "): GET " + path + " -> " + code + extra);
        }
    }

    /** Where the caller is: in the labelled copy's hold, waiting inside Spring Data Redis's cache writer, or neither (yet). */
    static String where(Thread t) {
        StackTraceElement[] st = t.getStackTrace();
        boolean writer = false, hold = false;
        for (StackTraceElement e : st) {
            if (e.getClassName().equals("com.tiffinbox.CustomerRepository") && e.getMethodName().startsWith("u17Hold")) hold = true;
            if (e.getClassName().startsWith("org.springframework.data.redis.cache.") && e.getClassName().contains("CacheWriter")) writer = true;
        }
        Thread.State s = t.getState();
        boolean parked = s == Thread.State.TIMED_WAITING || s == Thread.State.WAITING;
        if (hold && parked) return "inside the copy's hold in CustomerRepository.findAll (the harness holds - planted)";
        if (writer && !hold) return "waiting inside Spring Data Redis's cache writer, before the method";
        return null;
    }

    static void sync(String n) throws Exception {
        String jvm = "JVM " + n;
        var t = ctx.getBean(StringRedisTemplate.class);
        var repo = ctx.getBean(CustomerRepository.class);
        String hold = System.getProperty("u17.hold");
        p(jvm + " (" + who + "): the counter installed: " + Counter.installed + " · the hold: " + (hold == null ? "off (no hold)" : "on - the harness holds the caller inside findAll (planted, labelled)"));
        pause();
        p(jvm + ": at its poll on " + GO);
        int k = 0;
        while (!"1".equals(t.opsForValue().get(GO))) {
            if (++k >= 6000) throw new IllegalStateException(GO + " never read 1");
            Thread.sleep(5);
        }
        p(jvm + ": read " + GO + " = 1, polled " + k + " times - calling CustomerRepository.findAll() through the context's bean");
        long before = Counter.CALLS.get();
        AtomicReference<List<Customer>> got = new AtomicReference<>();
        AtomicReference<Throwable> err = new AtomicReference<>();
        Thread c = Thread.ofPlatform().name("u17-caller").start(() -> {
            try { got.set(repo.findAll()); } catch (Throwable e) { err.set(e); }
        });
        if (hold != null) {
            // the caller's place, read until the same answer comes STABLE times in a row (a count, never a clock): a caller that
            // passes through the cache writer on its way into the method is not read as waiting there
            String w = null, seen = null;
            int r = 0, same = 0;
            while (c.isAlive() && same < STABLE) {
                if (++r >= 12000) throw new IllegalStateException("the caller never settled in one place");
                w = where(c);
                if (w != null && w.equals(seen)) same++; else { seen = w; same = w == null ? 0 : 1; }
                Thread.sleep(5);
            }
            if (!c.isAlive()) w = null;
            p(jvm + "'s caller: " + (w == null ? "returned before parking" : w) + " · read " + r + " times");
        }
        c.join();
        if (err.get() != null) throw new IllegalStateException(err.get());
        long d = Counter.CALLS.get() - before;
        p(jvm + " (" + who + "): findAll() returned " + got.get().size() + " customers · the counter's delta (calls that reached Spring Data JPA's repository): " + d);
        pause();
    }

    static void hold() throws Exception {
        // the receipt answers this pause with SIGINT, never with ./go
        p("hold (" + who + "): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        p("hold: no SIGINT came");
    }
}
