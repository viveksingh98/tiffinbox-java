package probe.u13;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;

import javax.sql.DataSource;
import java.io.InputStream;
import java.lang.reflect.Field;
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
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 13's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), Counter (witness 1, calls
 * into Spring Data JPA's repository, unit 08's class copied) beside it, and Hibernate's statistics on (witness 2,
 * getPrepareStatementCount(), Course 7's pinned counter). psql and redis-cli are the receipt's second clients, run while this JVM
 * waits at a pause. args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info       the database that answered, the versions, the cache settings, the CacheManager bean, the cache names at the start
 *              and getCache("customer"), the Redis connection and the cache writer (when the manager is Redis's), the start's read
 *   http       GET /dashboard, /actuator/health and /actuator/health/readiness (java.net.http, 127.0.0.1)
 *   prom       GET /actuator/prometheus: its cache_gets_total lines counted per cache name
 *   reads      five calls of CustomerRepository.findAll(), one window
 *   byname     one findByName("Ravi") (the dev-shaped run's key for redis-cli)
 *   sync       Stampede's rounds on the anchor's own cached findAll, counts 2-32 (Stampede.java - no hold anywhere)
 *   plain      the same rounds at counts 2 and 4 (before/'s findAll, no sync - the contrast)
 *   nulls      findByName("Nobody") x3, the stored form, GET /customers/Nobody, a pause (psql inserts her), the lookup again,
 *              GET again, evict("Nobody"), the lookup again - on a copy without unless
 *   unless     findByName("Nobody") x3 and findByName("Ravi") x3, what is stored; then on a cold cache a lookup, a pause (psql
 *              inserts her), the lookup again - the anchor's own annotation
 *   cond       add(Sam), then the harness's HarnessCond.byName (condition = "#name.length() > 3", its own cache h13cond):
 *              Sam x3, Ravi x3
 *   nonull     findByName("Nobody") x3 with cache-null-values=false on Redis (a copy without unless): each call's outcome
 *   first      one findByName("Ravi"): its outcome (the syncunless copy)
 *   pause      waits for the receipt's file ./go (the receipt runs psql or redis-cli meanwhile), then goes on
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U13 {
    private U13() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;
    static String port = "";
    static String store = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class));
        if (steps.contains("cond")) src.add(HarnessCond.class);
        var app = new SpringApplication(src.toArray(new Class<?>[0]));
        int code = 0;
        try {
            ctx = app.run(rest);
        } catch (Throwable t) {
            System.out.println("PROBE started: no · " + t.getClass().getName());
            System.out.println("PROBE <<< exit 1");
            System.exit(1);
        }
        try {
            db = product(ctx.getBean(DataSource.class));
            port = ctx.getEnvironment().getProperty("local.server.port");
            CacheManager m = manager();
            store = m instanceof RedisCacheManager ? "Redis"
                    : m instanceof org.springframework.cache.caffeine.CaffeineCacheManager ? "in the JVM, Caffeine" : "in the JVM, a ConcurrentMap";
            p("started: yes · the database that answered: " + db + " · the cache's store: " + store + " · a web server: " + (port != null ? "yes" : "no"));
            for (String s : steps.split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            p("a step threw: " + t.getClass().getName() + ": " + first(t.getMessage()));
        }
        if (!ok) code = 1;
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

    static Statistics stats() {
        return ctx.getBean(EntityManagerFactory.class).unwrap(SessionFactory.class).getStatistics();
    }

    static CustomerRepository repo() {
        return ctx.getBean(CustomerRepository.class);
    }

    static CacheManager manager() {
        return ctx.getBean(CacheManager.class);
    }

    static Cache cache() {
        return manager().getCache("customers");
    }

    static Cache named() {
        return manager().getCache("customer");
    }

    static Object field(Object o, String name) throws Exception {
        for (Class<?> c = o.getClass(); c != null; c = c.getSuperclass()) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f.get(o);
            } catch (NoSuchFieldException e) {
                // the superclass, then
            }
        }
        return null;
    }

    static String last = "";

    static String get(String path) throws Exception {
        var c = HttpClient.newBuilder().proxy(HttpClient.Builder.NO_PROXY).build();
        var r = c.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        last = r.body();
        return String.valueOf(r.statusCode());
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "info" -> info();
            case "http" -> http();
            case "prom" -> prom();
            case "reads" -> reads();
            case "byname" -> byname();
            case "sync" -> Stampede.run(new int[] {2, 4, 8, 16, 32}, true);
            case "plain" -> Stampede.run(new int[] {2, 4}, false);
            case "nulls" -> nulls();
            case "unless" -> unless();
            case "cond" -> cond();
            case "nonull" -> nonull();
            case "first" -> firstCall();
            case "pause" -> pause();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt reads or writes the database or the store with its own client while this JVM is up, then writes ./go (no time
        // is measured)
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
        try (InputStream in = U13.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data Redis " + jarVersion(org.springframework.data.redis.core.RedisTemplate.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var env = ctx.getEnvironment();
        p("the environment: spring.cache.type " + env.getProperty("spring.cache.type", "unset")
                + " · spring.cache.cache-names " + env.getProperty("spring.cache.cache-names", "unset")
                + " · spring.cache.redis.cache-null-values " + env.getProperty("spring.cache.redis.cache-null-values", "unset"));
        Map<String, CacheManager> m = ctx.getBeansOfType(CacheManager.class);
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc + " (" + db + ")");
        CacheManager cm = manager();
        p("the cache names at the start, getCacheNames(): " + new TreeSet<>(cm.getCacheNames()));
        Cache c = named();
        p("getCache(\"customer\"): " + (c == null ? "null" : c.getClass().getName()));
        var cf = ctx.getBeanProvider(RedisConnectionFactory.class).getIfAvailable();
        if (cm instanceof RedisCacheManager rcm) {
            var lf = (org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory) cf;
            p("RedisConnectionFactory: " + cf.getClass().getName() + " · the connection: " + lf.getHostName() + ":" + lf.getPort());
            try (var conn = cf.getConnection()) {
                p("Redis's INFO server, through the connection: redis_version:" + conn.serverCommands().info("server").getProperty("redis_version"));
            }
            Object w = field(rcm, "cacheWriter");
            Object async = field(w, "asynchronousWrites");
            Object sleep = field(w, "sleepTime");
            p("the cache writer: " + w.getClass().getName() + " · asynchronousWrites " + async + " · a lock wait set "
                    + (sleep instanceof java.time.Duration d ? (d.isZero() ? "no (zero)" : "yes (not zero)") : "?"));
        }
        p("CustomerEntityRepository's bean: the counter installed: " + Counter.installed);
        var st = stats();
        p("the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here ("
                + db + "): repository calls " + Counter.CALLS.get() + " · prepareStatementCount " + st.getPrepareStatementCount());
    }

    static void http() throws Exception {
        for (String path : List.of("/dashboard", "/actuator/health", "/actuator/health/readiness")) {
            String code = get(path);
            String extra = "";
            if (path.startsWith("/actuator/health")) {
                Matcher top = Pattern.compile("\"status\":\"([A-Z_]+)\"\\}$").matcher(last.trim());
                extra = " · status " + (top.find() ? top.group(1) : "?");
            }
            p("http (" + db + ", " + store + "): GET " + path + " -> " + code + extra);
        }
    }

    static void prom() throws Exception {
        String code = get("/actuator/prometheus");
        var gets = new TreeMap<String, Integer>();
        var all = new TreeMap<String, Integer>();
        Pattern cn = Pattern.compile("^(cache_[a-z_]+)\\{.*cache=\"([a-z0-9]+)\"");
        for (String l : last.split("\n")) {
            Matcher mm = cn.matcher(l);
            if (!mm.find()) continue;
            all.merge(mm.group(2), 1, Integer::sum);
            if (mm.group(1).equals("cache_gets_total")) gets.merge(mm.group(2), 1, Integer::sum);
        }
        p("prometheus (" + db + ", " + store + "): GET /actuator/prometheus -> " + code + " · cache_gets_total lines per cache " + gets + " · every cache_ line per cache " + all);
    }

    record Delta(long inv, long sql) {}

    static Delta mark() {
        return new Delta(Counter.CALLS.get(), stats().getPrepareStatementCount());
    }

    static Delta since(Delta d) {
        return new Delta(Counter.CALLS.get() - d.inv, stats().getPrepareStatementCount() - d.sql);
    }

    static void compare(String label, List<Long> inv, List<Long> sql) {
        p(label + ": the two witnesses' per-call lists " + (inv.equals(sql) ? "equal" : "DIFFER"));
        if (!inv.equals(sql)) {
            ok = false;
            p("FAIL R.375: the invocation counter and the statement counter disagree");
        }
    }

    interface Call {
        Object run() throws Exception;
    }

    /** One window of calls: each call's repository calls and statements, the two lists compared. */
    static final class Window {
        final String label;
        final List<Long> inv = new ArrayList<>(), sql = new ArrayList<>();
        final List<String> got = new ArrayList<>();

        Window(String label) {
            this.label = label;
        }

        Object call(Call c) throws Exception {
            Delta d = mark();
            Object r;
            try {
                r = c.run();
                got.add(String.valueOf(r));
            } catch (Exception e) {
                got.add("threw " + e.getClass().getSimpleName());
                r = e;
            }
            Delta x = since(d);
            inv.add(x.inv);
            sql.add(x.sql);
            return r;
        }

        void close(String extra) {
            p(label + " (" + db + ", " + store + "): repository calls " + inv.stream().mapToLong(Long::longValue).sum() + " · prepareStatementCount "
                    + sql.stream().mapToLong(Long::longValue).sum() + " · per call " + inv + " and " + sql + extra);
            compare(label, inv, sql);
        }
    }

    static void reads() throws Exception {
        Window w = new Window("reads: five calls of CustomerRepository.findAll()");
        Object l = null;
        for (int i = 0; i < 5; i++) l = w.call(() -> repo().findAll());
        w.close(" · rows " + ((List<?>) l).size());
    }

    static void byname() throws Exception {
        Window w = new Window("byname: findByName(\"Ravi\")");
        w.call(() -> repo().findByName("Ravi"));
        w.close(" · returned " + w.got.get(0));
    }

    /** What the customer cache holds for a name: Caffeine's native entry's class (or null); on Redis the receipt reads the key. */
    static String stored(String name) {
        Cache c = named();
        if (c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> nc) {
            @SuppressWarnings("unchecked")
            Object v = ((com.github.benmanes.caffeine.cache.Cache<Object, Object>) nc).getIfPresent(name);
            return "getNativeCache().getIfPresent(\"" + name + "\") " + (v == null ? "null" : v.getClass().getName());
        }
        return "the receipt reads the key with redis-cli";
    }

    static String route(String name) throws Exception {
        Delta d = mark();
        String code = get("/customers/" + name);
        Delta x = since(d);
        return "GET /customers/" + name + " -> " + code + " · repository calls " + x.inv + " · prepareStatementCount " + x.sql;
    }

    static void nulls() throws Exception {
        named().clear();
        Window w = new Window("nulls: findByName(\"Nobody\") x3, psql inserts her, the lookup, evict(\"Nobody\"), the lookup");
        for (int i = 0; i < 3; i++) w.call(() -> repo().findByName("Nobody"));
        p("nulls: the first three lookups returned " + w.got + " · per call " + w.inv);
        p("nulls: the stored form, in the cache customer: " + stored("Nobody"));
        p("nulls: TiffinBoxServer's route, before the insert: " + route("Nobody"));
        pause();
        w.call(() -> repo().findByName("Nobody"));
        p("nulls: after psql's insert, the lookup returned " + w.got.get(3) + " · repository calls " + w.inv.get(3) + " · prepareStatementCount " + w.sql.get(3));
        p("nulls: TiffinBoxServer's route, after the insert: " + route("Nobody"));
        named().evict("Nobody");
        w.call(() -> repo().findByName("Nobody"));
        p("nulls: after evict(\"Nobody\"), the lookup returned " + w.got.get(4) + " · repository calls " + w.inv.get(4) + " · prepareStatementCount " + w.sql.get(4));
        w.close(" · invocations " + w.inv.subList(0, 3).stream().mapToLong(Long::longValue).sum() + " -> "
                + w.inv.subList(0, 4).stream().mapToLong(Long::longValue).sum() + " (the insert) -> " + w.inv.stream().mapToLong(Long::longValue).sum() + " (the evict)");
    }

    static void unless() throws Exception {
        named().clear();
        Window a = new Window("unless: findByName(\"Nobody\") x3");
        for (int i = 0; i < 3; i++) a.call(() -> repo().findByName("Nobody"));
        a.close(" · returned " + new TreeSet<>(a.got));
        p("unless: after Nobody x3, in the cache customer: " + stored("Nobody"));
        Window b = new Window("unless: findByName(\"Ravi\") x3");
        for (int i = 0; i < 3; i++) b.call(() -> repo().findByName("Ravi"));
        b.close(" · returned " + new TreeSet<>(b.got));
        p("unless: after Ravi x3, in the cache customer: " + stored("Ravi"));
        pause();
        named().clear();
        Window c = new Window("unless: on a cold cache, findByName(\"Nobody\"), psql inserts her, findByName(\"Nobody\")");
        c.call(() -> repo().findByName("Nobody"));
        p("unless: the lookup before the insert returned " + c.got.get(0));
        pause();
        c.call(() -> repo().findByName("Nobody"));
        p("unless: the lookup after psql's insert returned " + c.got.get(1));
        c.close(" · invocations " + c.inv.get(0) + " -> " + (c.inv.get(0) + c.inv.get(1)));
    }

    static void cond() throws Exception {
        var h = ctx.getBean(HarnessCond.Lookups.class);
        p("cond: a harness bean, not the anchor's cache - HarnessCond.Lookups, its cache h13cond (condition = \"#name.length() > 3\"); the cache names at the start "
                + new TreeSet<>(manager().getCacheNames()));
        boolean sam = repo().findByName("Sam").isPresent();
        if (!sam) repo().add(new Customer("Sam", 1, 110, "VEG"));
        p("cond: Sam in the seed: " + sam + (sam ? "" : " - added through add(Sam) first"));
        Window w = new Window("cond: HarnessCond byName(\"Sam\") x3, then byName(\"Ravi\") x3");
        for (String n : List.of("Sam", "Sam", "Sam", "Ravi", "Ravi", "Ravi")) w.call(() -> h.byName(n));
        w.close(" · returned " + w.got);
    }

    static void nonull() throws Exception {
        named().clear();
        Window w = new Window("nonull: findByName(\"Nobody\") x3, spring.cache.redis.cache-null-values=false");
        var msgs = new ArrayList<String>();
        for (int i = 0; i < 3; i++) {
            Object r = w.call(() -> repo().findByName("Nobody"));
            msgs.add(r instanceof Exception e ? e.getClass().getName() + ": " + first(e.getMessage()) : "returned " + r);
        }
        for (int i = 0; i < 3; i++) p("nonull: call " + (i + 1) + ": " + msgs.get(i));
        w.close(" · outcomes " + w.got);
    }

    static void firstCall() throws Exception {
        Window w = new Window("first: findByName(\"Ravi\"), the first cached call");
        Object r = w.call(() -> repo().findByName("Ravi"));
        p("first: " + (r instanceof Exception e ? e.getClass().getName() + ": " + first(e.getMessage()) : "returned " + r));
        w.close("");
    }
}
