package probe.u16;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.context.annotation.Profile;
import org.springframework.data.domain.Range;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.stream.MapRecord;
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
import java.util.Map;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 16's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), started as the receipt
 * says - under the profile "dev" on PostgreSQL + Redis, or the default run on H2 - and read through the context's own beans and its
 * own JSON API: a customer added by POST /customers reaches the stream through the shipped KitchenEvents (after add's commit), and
 * the harness reads the stream back by the context's StringRedisTemplate (witness 1) while the receipt reads it by redis-cli inside
 * the Redis container and the rows by psql (witness 2, R.398), at a pause. Nothing here writes to Redis: the only XADD is
 * KitchenEvents'. args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info     the database, the profiles, the versions, the KitchenEvents beans (class, profile), the StringRedisTemplate beans, the Redis
 *            connection's INFO server line (under "dev")
 *   http     GET /dashboard, /actuator/health, /leaderboard, /kitchen (java.net.http, 127.0.0.1)
 *   add=NAME POST /customers {NAME, 2 meals, 110, VEGAN} - its status
 *   stream   the stream by Java (under "dev"): XLEN, TYPE, every entry's id (time part &lt;t&gt;) and fields in the order Redis returns
 *            them; then a pause (the receipt reads redis-cli and psql)
 *   noevents the default run: the KitchenEvents beans and the StringRedisTemplate beans
 *   hold     a pause the receipt answers with SIGINT (the JVM's exit is 130)
 */
public final class U16 {
    private U16() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static String port = "";
    static String who = "";
    static final String KEY = "tiffinbox:kitchen-events";

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

    static HttpClient http = HttpClient.newBuilder().proxy(HttpClient.Builder.NO_PROXY).build();

    static String get(String path) throws Exception {
        var r = http.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        last = r.body();
        return String.valueOf(r.statusCode());
    }

    static void step(String s) throws Exception {
        if (s.startsWith("add=")) { add(s.substring(4)); return; }
        switch (s) {
            case "info" -> info();
            case "http" -> http();
            case "stream" -> stream();
            case "noevents" -> noevents();
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
        System.out.flush();
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static Class<?> events() throws Exception {
        return Class.forName("com.tiffinbox.web.KitchenEvents");
    }

    static void beans() throws Exception {
        var ke = new ArrayList<String>();
        for (var e : ctx.getBeansOfType(events()).entrySet()) {
            Profile pr = AnnotationUtils.findAnnotation(e.getValue().getClass(), Profile.class);
            ke.add(e.getKey() + "=" + e.getValue().getClass().getName() + " @Profile" + (pr == null ? "(none)" : Arrays.toString(pr.value())));
        }
        p("KitchenEvents beans " + ke.size() + " " + ke + " (" + who + ")");
        p("StringRedisTemplate beans " + new TreeSet<>(ctx.getBeansOfType(StringRedisTemplate.class).keySet()) + " (" + who + ")");
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U16.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Redis " + jarVersion(RedisTemplate.class)
                + " · Lettuce " + jarVersion(io.lettuce.core.RedisClient.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        beans();
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

    static void add(String name) throws Exception {
        String body = "{\"name\":\"" + name + "\",\"mealsPerDay\":2,\"pricePerMeal\":110,\"mealType\":\"VEGAN\"}";
        var r = http.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + "/customers")).header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body)).build(), HttpResponse.BodyHandlers.ofString());
        p("add (" + who + "): POST /customers " + body + " -> " + r.statusCode());
    }

    static void stream() throws Exception {
        var t = ctx.getBean(StringRedisTemplate.class);
        List<MapRecord<String, Object, Object>> all = t.opsForStream().range(KEY, Range.unbounded());
        var es = new ArrayList<String>();
        for (var r : all) {
            var f = new ArrayList<String>();
            r.getValue().forEach((k, v) -> f.add(k + " " + v));
            es.add(r.getId().getValue().replaceFirst("^[0-9]+-", "<t>-") + " " + String.join(" ", f));
        }
        p("stream (" + who + ", the context's StringRedisTemplate - KitchenEvents' writes): XLEN " + t.opsForStream().size(KEY) + " · TYPE " + t.type(KEY).code() + " · entries " + es);
        pause();
    }

    static void noevents() throws Exception {
        beans();
        p("noevents (" + who + "): getBeansOfType(KitchenEvents) " + ctx.getBeansOfType(events()).size());
    }

    static void hold() throws Exception {
        // the receipt answers this pause with SIGINT, never with ./go
        p("hold (" + who + "): pid " + ProcessHandle.current().pid());
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400; i++) Thread.sleep(50);
        p("hold: no SIGINT came");
    }
}
