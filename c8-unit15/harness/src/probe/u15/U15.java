package probe.u15;

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
 * Unit 15's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), started as the receipt
 * says - under the profile "dev" on PostgreSQL + Redis, or the default run on H2 - and read through the context's own beans: the
 * start's own saves, through the shipped KitchenOrders (witness 1), beside redis-cli inside the Redis container, which the receipt
 * runs while this JVM waits at a pause (witness 2, R.398). The harness's three orders are not saved here (H15.java: every TiffinBox
 * start saves its own orders). args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info     the database that answered, the profiles, the versions, the CacheManager, Leaderboard, KitchenOrders and RedisDatastore
 *            beans, the Redis connection, its INFO server line and CONFIG GET notify-keyspace-events (when one is configured)
 *   http     GET /dashboard, /actuator/health, /actuator/health/readiness, /leaderboard and /kitchen (java.net.http, 127.0.0.1)
 *   rail     the start's orders through the shipped KitchenOrders: count(), the ids sorted (their count and md5), per customer and per
 *            meal type the finders' sizes, findById of the first id and the ttl it carries ("set" when one is); a pause
 *   railgone after the receipt's poll (the start's orders gone, their sets emptied by the listener): count(), findAll()'s size
 *   noorders the default run: KitchenOrders and RedisDatastore beans
 *   hold     a pause the receipt answers with SIGINT (the JVM's exit is 130)
 * Nothing here writes to Redis: the only writes are the start's own (the leaderboard and the orders).
 */
public final class U15 {
    private U15() {}

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
            case "rail" -> rail();
            case "railgone" -> railgone();
            case "noorders" -> noorders();
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
        try (InputStream in = U15.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
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
        var ko = new ArrayList<String>();
        ctx.getBeansOfType(com.tiffinbox.web.KitchenOrders.class).forEach((k, v) -> ko.add(k + "=" + (v instanceof java.lang.reflect.Proxy ? "a JDK proxy of " + String.join(",", Arrays.stream(v.getClass().getInterfaces()).map(Class::getName).filter(x -> x.startsWith("com.tiffinbox")).toList()) : v.getClass().getName())));
        p("KitchenOrders beans " + ko.size() + " " + ko + " · RedisDatastore beans " + ctx.getBeanNamesForType(Class.forName("com.tiffinbox.web.RedisDatastore")).length + " (" + who + ")");
        if ("dev".equals(String.join(",", ctx.getEnvironment().getActiveProfiles()))) {
            var cf = ctx.getBean(RedisConnectionFactory.class);
            var lf = (org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory) cf;
            p("RedisConnectionFactory: " + cf.getClass().getName() + " · the connection: " + lf.getHostName() + ":" + lf.getPort());
            try (var conn = cf.getConnection()) {
                p("Redis's INFO server, through the connection: redis_version:" + conn.serverCommands().info("server").getProperty("redis_version"));
                p("CONFIG GET notify-keyspace-events, through the connection, after the start: \"" + conn.serverCommands().getConfig("notify-keyspace-events").getProperty("notify-keyspace-events") + "\"");
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

    static com.tiffinbox.web.KitchenOrders orders() {
        return ctx.getBean(com.tiffinbox.web.KitchenOrders.class);
    }

    static List<com.tiffinbox.web.KitchenOrder> all() {
        var out = new ArrayList<com.tiffinbox.web.KitchenOrder>();
        orders().findAll().forEach(out::add);
        return out;
    }

    static void rail() throws Exception {
        var o = orders();
        var ids = new TreeSet<String>();
        int nulls = 0;
        for (var k : all()) if (k == null) nulls++; else ids.add(k.getId());
        String md5 = java.util.HexFormat.of().formatHex(java.security.MessageDigest.getInstance("MD5").digest((String.join("\n", ids) + "\n").getBytes(StandardCharsets.UTF_8)));
        p("rail (the start's saves, through the shipped KitchenOrders; " + who + "): count() " + o.count() + " · findAll() " + (ids.size() + nulls) + " elements, " + nulls
                + " null · the ids, sorted: " + ids.size() + ", first " + ids.first() + ", last " + ids.last() + ", md5 of the sorted lines " + md5);
        var per = new ArrayList<String>();
        for (Customer c : ctx.getBean(CustomerRepository.class).findAll()) per.add(c.name() + " " + o.findByCustomer(c.name()).size());
        var types = new ArrayList<String>();
        for (var m : ctx.getBean(TiffinBoxProperties.class).mealTypes()) types.add(m.name() + " " + o.findByMealType(m.name()).size());
        p("rail: findByCustomer, per customer: " + String.join(" · ", per) + " · findByMealType, per meal type: " + String.join(" · ", types));
        var first = o.findById(ids.first()).orElseThrow();
        p("rail: findById(" + ids.first() + ") " + first + " · its ttl: " + (first.getTtl() == null ? "null" : first.getTtl() > 0 ? "set" : String.valueOf(first.getTtl())));
        pause();
    }

    static void railgone() throws Exception {
        var a = all();
        int nulls = 0;
        for (var k : a) if (k == null) nulls++;
        p("railgone (the start's saves, after their time to live; " + who + "): count() " + orders().count() + " · findAll() " + a.size() + " elements, " + nulls + " null");
    }

    static void noorders() throws Exception {
        p("noorders (" + who + "): getBeansOfType(KitchenOrders) " + ctx.getBeansOfType(com.tiffinbox.web.KitchenOrders.class).size()
                + " · a bean of class com.tiffinbox.web.RedisDatastore " + ctx.getBeanNamesForType(Class.forName("com.tiffinbox.web.RedisDatastore")).length);
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
