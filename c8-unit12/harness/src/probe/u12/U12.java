package probe.u12;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.CustomerRepository;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.interceptor.SimpleKey;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.jdbc.core.JdbcTemplate;

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
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 12's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), Counter (witness 1, calls
 * into Spring Data JPA's repository, copied from unit 08's harness) beside it, and Hibernate's statistics on (witness 2,
 * getPrepareStatementCount(), Course 7's pinned counter). psql and redis-cli are the receipt's second clients, run while this JVM
 * waits at a pause. args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info     the database that answered, the versions, the cache settings the environment holds (a time-to-live value masked to
 *            "set"), the CacheManager bean and its class, the cache's class, Caffeine's policy read back through
 *            Cache.getNativeCache() (expireAfterWrite present or absent, the ceiling, recordStats), the Redis connection and the
 *            cache writer (when the manager is Redis's), and the start's own read in its own window
 *   http     GET /dashboard, /actuator/health and /actuator/health/readiness (java.net.http, 127.0.0.1)
 *   reads    five calls of CustomerRepository.findAll(), one window; Caffeine's counts after them (when the cache is Caffeine's)
 *   stale    a read, then JdbcTemplate.update around the cache, a pause (the receipt's psql reads the row), the cached read again;
 *            then the control - the cache emptied, a read, add(a new name) through the cache's @CacheEvict, a read
 *   pinned   the stale shape alone: a read, the JdbcTemplate update, the row read back by JdbcTemplate, the cached read again
 *   evict    a read (the rows), add(a new name) - @CacheEvict(allEntries = true) - and a read: both reads in one window
 *   put      the harness's own @CachePut / @Cacheable pair on its own cache h12put (HarnessPut - a harness bean, not the anchor's)
 *   ttl      a read, the key present, a pause (the receipt's redis-cli), a bounded poll until the key is gone (Caffeine's
 *            getIfPresent null / Redis's EXISTS 0 - the condition, never a timed wait), a pause, a read
 *   stampede Stampede's rounds on the anchor's own cached findAll (Stampede.java - no hold anywhere)
 *   pause    waits for the receipt's file ./go (the receipt runs psql or redis-cli meanwhile), then goes on
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U12 {
    private U12() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;
    static String port = "";
    static String store = "";
    static final String KEY = "customers::SimpleKey []";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class));
        if (steps.contains("put")) src.add(HarnessPut.class);
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

    static JdbcTemplate jdbc() {
        return new JdbcTemplate(ctx.getBean(DataSource.class));
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
            case "reads" -> reads();
            case "stale" -> stale();
            case "pinned" -> pinned();
            case "evict" -> evict();
            case "put" -> put();
            case "ttl" -> ttl();
            case "stampede" -> Stampede.run();
            case "pause" -> pause();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static int pauses = 0;

    static void pause() throws Exception {
        // the receipt reads the database or the store with its own client while this JVM is up, then writes ./go (no time is measured)
        Path go = Path.of("go");
        pauses++;
        p("pause " + pauses + ": the receipt reads now");
        System.out.flush();
        for (int i = 0; i < 2400 && !Files.exists(go); i++) Thread.sleep(50);
        p("pause " + pauses + ": resumed " + (Files.exists(go) ? "by the receipt" : "without the receipt's go"));
        Files.deleteIfExists(go);
    }

    static String spec(String v) {
        return v == null ? "unset" : v.replaceAll("expireAfterWrite=[0-9]+[a-z]?", "expireAfterWrite=<n>");
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U12.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data Redis " + jarVersion(org.springframework.data.redis.core.RedisTemplate.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var env = ctx.getEnvironment();
        p("the environment: spring.cache.type " + env.getProperty("spring.cache.type", "unset")
                + " · spring.cache.cache-names " + env.getProperty("spring.cache.cache-names", "unset")
                + " · spring.cache.caffeine.spec " + spec(env.getProperty("spring.cache.caffeine.spec"))
                + " · spring.cache.redis.time-to-live " + (env.getProperty("spring.cache.redis.time-to-live") == null ? "unset" : "set"));
        Map<String, CacheManager> m = ctx.getBeansOfType(CacheManager.class);
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc + " (" + db + ")");
        CacheManager cm = manager();
        p("the cache names at the start, getCacheNames(): " + new TreeSet<>(cm.getCacheNames()));
        Cache c = cache();
        p("cache customers: " + c.getClass().getName() + " · native " + c.getNativeCache().getClass().getName());
        if (c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> nc) {
            var pol = nc.policy();
            var exp = pol.expireAfterWrite();
            String val = "";
            if (exp.isPresent()) {
                String sp = env.getProperty("spring.cache.caffeine.spec", "");
                Matcher mm = Pattern.compile("expireAfterWrite=([0-9]+)([smhd])").matcher(sp);
                String same = "?";
                if (mm.find()) {
                    long n = Long.parseLong(mm.group(1));
                    var unit = switch (mm.group(2)) {
                        case "s" -> java.util.concurrent.TimeUnit.SECONDS;
                        case "m" -> java.util.concurrent.TimeUnit.MINUTES;
                        case "h" -> java.util.concurrent.TimeUnit.HOURS;
                        default -> java.util.concurrent.TimeUnit.DAYS;
                    };
                    same = exp.get().getExpiresAfter(unit) == n ? "yes" : "no";
                }
                val = " · its value = the spec's expireAfterWrite=<n>: " + same;
            }
            p("Caffeine's policy, read back through Cache.getNativeCache().policy(): expireAfterWrite() " + (exp.isPresent() ? "Optional[…] (present)" : "Optional.empty (absent)")
                    + val + " · eviction().getMaximum() " + pol.eviction().map(e -> String.valueOf(e.getMaximum())).orElse("none")
                    + " · isRecordingStats() " + pol.isRecordingStats());
        }
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

    /** One window of calls of findAll(): each call's repository calls and statements, the two lists compared. */
    static final class Window {
        final String label;
        final Delta start = mark();
        final List<Long> inv = new ArrayList<>(), sql = new ArrayList<>();
        List<Customer> lastList;

        Window(String label) {
            this.label = label;
        }

        List<Customer> read() throws Exception {
            Delta d = mark();
            lastList = repo().findAll();
            Delta x = since(d);
            inv.add(x.inv);
            sql.add(x.sql);
            return lastList;
        }

        void close(String extra) {
            Delta t = since(start);
            p(label + " (" + db + ", " + store + "): repository calls " + inv.stream().mapToLong(Long::longValue).sum() + " · prepareStatementCount "
                    + sql.stream().mapToLong(Long::longValue).sum() + " · per call " + inv + " and " + sql + extra);
            compare(label, inv, sql);
        }
    }

    static int meals(List<Customer> l, String name) {
        return l.stream().filter(c -> c.name().equals(name)).mapToInt(Customer::mealsPerDay).findFirst().orElse(-1);
    }

    static String caffeineCounts() {
        if (cache().getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> nc) {
            var s = nc.stats();
            return "hitCount " + s.hitCount() + " · missCount " + s.missCount() + " · estimatedSize " + nc.estimatedSize();
        }
        return "";
    }

    static void reads() throws Exception {
        Window w = new Window("reads: five calls of CustomerRepository.findAll()");
        for (int i = 0; i < 5; i++) w.read();
        w.close(" · rows " + w.lastList.size());
        String cc = caffeineCounts();
        if (!cc.isEmpty()) p("reads: Caffeine's counts (a third witness): " + cc);
    }

    static final String UPDATE = "update customer set meals_per_day = 3 where name = 'Ravi'";

    static void stale() throws Exception {
        cache().clear();
        Window w = new Window("stale: the read, the write around the cache, the read again");
        int before = meals(w.read(), "Ravi");
        p("stale: read 1 - Ravi's meals " + before);
        int rows = jdbc().update(UPDATE);
        p("stale: JdbcTemplate.update(\"" + UPDATE + "\") -> " + rows + " row");
        pause();
        String out;
        int after = -1;
        try {
            after = meals(w.read(), "Ravi");
            out = "returned";
        } catch (Exception e) {
            out = "threw " + e.getClass().getName();
        }
        p("stale: read 2 (the cached read) - Ravi's meals " + after + " · repository calls " + w.inv.get(1) + " · prepareStatementCount " + w.sql.get(1) + " · " + out);
        w.close(" · the cached read says " + after + ", the row now " + jdbc().queryForObject("select meals_per_day from customer where name = 'Ravi'", Integer.class) + " (JdbcTemplate)");
        cache().clear();
        Window c = new Window("stale control: the cache emptied, a read, add(Oscar) through the cache, a read");
        int n = c.read().size();
        repo().add(new Customer("Oscar", 1, 110, "VEG"));
        List<Customer> l = c.read();
        c.close(" · rows " + n + " -> " + l.size() + " · Oscar in the second read: " + l.stream().anyMatch(x -> x.name().equals("Oscar")) + " · Ravi's meals " + meals(l, "Ravi"));
    }

    static void pinned() throws Exception {
        cache().clear();
        Window w = new Window("pinned: the read, the write around the cache, the read again");
        int before = meals(w.read(), "Ravi");
        int rows = jdbc().update(UPDATE);
        int row = jdbc().queryForObject("select meals_per_day from customer where name = 'Ravi'", Integer.class);
        int after = meals(w.read(), "Ravi");
        w.close(" · Ravi's meals: read " + before + " · JdbcTemplate update " + rows + " row · row now " + row + " · cached read says " + after);
    }

    static void evict() throws Exception {
        cache().clear();
        Window w = new Window("evict: a read, add(Hannah) - @CacheEvict(allEntries = true) - a read");
        int n = w.read().size();
        repo().add(new Customer("Hannah", 2, 130, "VEGAN"));
        List<Customer> l = w.read();
        w.close(" · rows " + n + " -> " + l.size() + " · Hannah in the second read: " + l.stream().anyMatch(x -> x.name().equals("Hannah")));
    }

    static void put() throws Exception {
        var h = ctx.getBean(HarnessPut.Meals.class);
        p("put: a harness bean, not the anchor's cache - HarnessPut.Meals, its cache h12put; the cache names at the start " + new TreeSet<>(manager().getCacheNames()));
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        var got = new ArrayList<String>();
        for (int meals : new int[] {2, 3}) {
            Delta d = mark();
            got.add(h.write("Ravi", meals));
            Delta x = since(d);
            inv.add(x.inv);
            sql.add(x.sql);
        }
        Delta d = mark();
        String r = h.read("Ravi");
        Delta x = since(d);
        inv.add(x.inv);
        sql.add(x.sql);
        p("put (" + db + ", " + store + "): @CachePut write(\"Ravi\", 2), write(\"Ravi\", 3), then @Cacheable read(\"Ravi\"): per call " + inv + " and " + sql
                + " · the writes returned " + got + " · the read returned \"" + r + "\"");
        compare("put", inv, sql);
    }

    static int keys() throws Exception {
        if (manager() instanceof RedisCacheManager) {
            try (var conn = ctx.getBean(RedisConnectionFactory.class).getConnection()) {
                return Boolean.TRUE.equals(conn.keyCommands().exists(KEY.getBytes(StandardCharsets.UTF_8))) ? 1 : 0;
            }
        }
        return cache().get(SimpleKey.EMPTY) != null ? 1 : 0;
    }

    static void ttl() throws Exception {
        cache().clear();
        String how = manager() instanceof RedisCacheManager ? "EXISTS \"" + KEY + "\" through the connection" : "getIfPresent(SimpleKey []) on the native cache, non-null";
        Window w = new Window("ttl: a read, the key gone, a read");
        w.read();
        p("ttl: after read 1 - keys " + keys() + " (" + how + ")" + (caffeineCounts().isEmpty() ? "" : " · estimatedSize " + estimated()));
        pause();
        int polls = 0;
        while (keys() == 1 && polls < 4000) {
            polls++;
            Thread.sleep(10);
        }
        int k = keys();
        p("ttl: the harness polled the condition (keys 0), bounded, under the JVM's alarm - keys " + k + (k == 0 ? "" : " (the poll's bound reached)"));
        if (k != 0) ok = false;
        String size = "";
        if (cache().getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> nc) {
            System.err.println("U12-RAW ttl: estimatedSize when getIfPresent first returned null: " + nc.estimatedSize() + " (Caffeine's lazy expiry - varies, not in the capture)");
            nc.cleanUp();
            size = " · estimatedSize after cleanUp() " + nc.estimatedSize();
        }
        p("ttl: keys " + k + size);
        pause();
        w.read();
        w.close(" · invocations " + w.inv.get(0) + " -> " + (w.inv.get(0) + w.inv.get(1)) + " · keys after read 2: " + keys());
    }

    static long estimated() {
        return ((com.github.benmanes.caffeine.cache.Cache<?, ?>) cache().getNativeCache()).estimatedSize();
    }
}
