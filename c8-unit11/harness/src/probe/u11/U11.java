package probe.u11;

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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Unit 11's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), Counter (witness 1, calls
 * into Spring Data JPA's repository, copied from unit 08's harness) beside it, and Hibernate's statistics on (witness 2,
 * getPrepareStatementCount(), Course 7's pinned counter). The store's own client, redis-cli, is the receipt's (a third witness,
 * between and after these JVMs). args[0] is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info    the database that answered, the versions, the settings the environment holds, the CacheManager beans and their
 *           class, the cache names, RedisCaching's two beans (present or absent), the Redis connection and the cache writer (when
 *           the manager is Redis's), and the start's own read in its own window
 *   http    GET /dashboard, /actuator/health and /actuator/health/readiness (java.net.http, 127.0.0.1): status, and health's
 *           components with their status
 *   reads   five calls of CustomerRepository.findAll() through the context's bean, one window; the classes read back
 *   one     one call, its own window; every customer the call returned, as Java prints the record
 *   two     two calls, each in a window of its own; a call that throws prints its exception, and the window still counts
 *   evict   ten rounds of: a read, add(a new name) - @CacheEvict(allEntries = true) - and an immediate read: stale reads (the
 *           new name missing) counted (the next read's count varies run to run: stderr only); then fifty rounds of evictIfPresent, put and an immediate read on the same cache
 *           and key: whether a read right after a put reached the repository (its count varies run to run: stderr only)
 *   pause   waits for the receipt's file ./go (the receipt runs redis-cli meanwhile), then goes on
 *   nullv   the harness's own @Cacheable("h11") method returning null, twice (HarnessNull - a harness bean, not the anchor's)
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U11 {
    private U11() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;
    static String port = "";
    static String store = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class));
        if (steps.contains("nullv")) src.add(HarnessNull.class);
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
            store = manager() instanceof RedisCacheManager ? "Redis" : "in the JVM, Caffeine";
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

    static String get(String path) throws Exception {
        var c = HttpClient.newBuilder().proxy(HttpClient.Builder.NO_PROXY).build();
        var r = c.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path)).GET().build(), HttpResponse.BodyHandlers.ofString());
        last = r.body();
        return String.valueOf(r.statusCode());
    }

    static String last = "";

    static void step(String s) throws Exception {
        switch (s) {
            case "info" -> info();
            case "http" -> http();
            case "reads" -> reads();
            case "one" -> one();
            case "two" -> {
                call("two: call 1 of CustomerRepository.findAll()");
                call("two: call 2 of CustomerRepository.findAll()");
            }
            case "evict" -> evict();
            case "nullv" -> nullv();
            case "pause" -> {
                // the receipt reads the store with its own client while this JVM is up, then writes ./go (no time is measured)
                java.nio.file.Path go = java.nio.file.Path.of("go");
                p("pause: the receipt reads the store now");
                System.out.flush();
                for (int i = 0; i < 1200 && !java.nio.file.Files.exists(go); i++) Thread.sleep(50);
                p("pause: resumed " + (java.nio.file.Files.exists(go) ? "by the receipt" : "without the receipt's go"));
                java.nio.file.Files.deleteIfExists(go);
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U11.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Spring Data Redis " + jarVersion(org.springframework.data.redis.core.RedisTemplate.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var env = ctx.getEnvironment();
        p("the environment: spring.cache.type " + env.getProperty("spring.cache.type", "unset")
                + " · spring.cache.cache-names " + env.getProperty("spring.cache.cache-names", "unset")
                + " · management.health.redis.enabled " + env.getProperty("management.health.redis.enabled", "unset")
                + " · spring.cache.redis.time-to-live " + (env.getProperty("spring.cache.redis.time-to-live") == null ? "unset" : "set")
                + " · spring.cache.redis.key-prefix " + env.getProperty("spring.cache.redis.key-prefix", "unset")
                + " · spring.profiles.active " + env.getProperty("spring.profiles.active", "unset"));
        Map<String, CacheManager> m = ctx.getBeansOfType(CacheManager.class);
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc + " (" + db + ")");
        CacheManager cm = manager();
        p("the cache names at the start, getCacheNames(): " + new TreeSet<>(cm.getCacheNames()));
        if (cm.getCacheNames().contains("customers")) {
            Cache c = cm.getCache("customers");
            p("cache customers: " + c.getClass().getName() + " · native " + c.getNativeCache().getClass().getName());
        }
        p("RedisCaching (com.tiffinbox.web): its configuration bean " + (ctx.containsBean("redisCaching") ? "present" : "absent")
                + " · RedisCacheManagerBuilderCustomizer beans " + new TreeSet<>(List.of(ctx.getBeanNamesForType(org.springframework.boot.cache.autoconfigure.RedisCacheManagerBuilderCustomizer.class)))
                + " · RedisCacheConfiguration beans " + new TreeSet<>(List.of(ctx.getBeanNamesForType(org.springframework.data.redis.cache.RedisCacheConfiguration.class))));
        var cd = new TreeSet<String>();
        for (String b : ctx.getBeanDefinitionNames()) if (b.contains("ConnectionDetails")) cd.add(b);
        p("the beans named ...ConnectionDetails...: " + cd);
        var cf = ctx.getBeanProvider(RedisConnectionFactory.class).getIfAvailable();
        p("RedisConnectionFactory: " + (cf == null ? "none" : cf.getClass().getName()));
        if (cm instanceof RedisCacheManager rcm) {
            var lf = (org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory) cf;
            p("the connection: " + lf.getHostName() + ":" + lf.getPort());
            try (var conn = cf.getConnection()) {
                p("Redis's INFO server, through the connection: redis_version:" + conn.serverCommands().info("server").getProperty("redis_version"));
            }
            Object w = field(rcm, "cacheWriter");
            Object async = field(w, "asynchronousWrites");
            Object sleep = field(w, "sleepTime");
            p("the cache writer: " + w.getClass().getName() + " · asynchronousWrites " + async + " · a lock wait set "
                    + (sleep instanceof java.time.Duration d ? (d.isZero() ? "no (zero)" : "yes (not zero)") : "?"));
            var conf = rcm.getCacheConfigurations().get("customers");
            if (conf != null) {
                Object reader = conf.getValueSerializationPair().getReader();
                Object ser = field(reader, "serializer");
                p("the customers cache's configuration: value serializer " + (ser == null ? reader.getClass().getName() : ser.getClass().getName())
                        + " · key prefix for customers \"" + conf.getKeyPrefixFor("customers") + "\" · null values allowed " + conf.getAllowCacheNullValues());
            }
        }
        Object er = ctx.getBean(CustomerEntityRepository.class);
        p("CustomerEntityRepository's bean: a " + (er instanceof org.springframework.aop.framework.Advised ? "Spring AOP proxy (Advised)" : "plain object")
                + " · the counter installed: " + Counter.installed);
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
                int ci = last.indexOf("\"components\":");
                if (ci >= 0) {
                    var comps = new TreeSet<String>();
                    Matcher c = Pattern.compile("\"([A-Za-z]+)\":\\{\"status\":\"([A-Z_]+)\"").matcher(last.substring(ci));
                    while (c.find()) comps.add(c.group(1) + " " + c.group(2));
                    extra += " · components " + comps;
                } else extra += " · components not shown";
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

    static void reads() throws Exception {
        String label = "reads: five calls of CustomerRepository.findAll()";
        Delta w = mark();
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        List<Customer> firstList = null, lastList = null;
        for (int i = 0; i < 5; i++) {
            Delta d = mark();
            List<Customer> l = repo().findAll();
            if (firstList == null) firstList = l;
            lastList = l;
            Delta x = since(d);
            inv.add(x.inv);
            sql.add(x.sql);
        }
        Delta t = since(w);
        p(label + " (" + db + ", " + store + "): repository calls " + t.inv + " · prepareStatementCount " + t.sql + " · per call " + inv + " and " + sql + " · rows " + lastList.size());
        compare(label, inv, sql);
        p("reads: the classes read back - call 1 (the miss): " + firstList.getClass().getName() + " of " + firstList.get(0).getClass().getName()
                + " · call 5 (a hit): " + lastList.getClass().getName() + " of " + new TreeSet<>(lastList.stream().map(c -> c.getClass().getName()).toList()));
    }

    static void one() throws Exception {
        String label = "one: one call of CustomerRepository.findAll()";
        Delta d = mark();
        String out;
        List<Customer> l = null;
        try {
            l = repo().findAll();
            out = "returned";
        } catch (Exception e) {
            out = "threw " + e.getClass().getName() + ": " + first(e.getMessage());
            for (Throwable c = e.getCause(); c != null; c = c.getCause()) out += " <- " + c.getClass().getName() + ": " + first(c.getMessage());
        }
        Delta x = since(d);
        p(label + " (" + db + ", " + store + "): repository calls " + x.inv + " · prepareStatementCount " + x.sql + " · per call [" + x.inv + "] and [" + x.sql + "] · " + out);
        compare(label, List.of(x.inv), List.of(x.sql));
        if (l != null) {
            p("one: the list read back: " + l.getClass().getName() + ", " + l.size() + " elements");
            for (Customer c : l) p("one: element " + c.getClass().getName() + " = " + c);
        }
    }

    static void call(String label) throws Exception {
        Delta d = mark();
        String out;
        try {
            List<Customer> l = repo().findAll();
            out = "returned " + l.getClass().getName() + " of " + new TreeSet<>(l.stream().map(c -> c.getClass().getName()).toList()) + ", " + l.size() + " elements";
        } catch (Exception e) {
            out = "threw " + e.getClass().getName() + ": " + first(e.getMessage());
            for (Throwable c = e.getCause(); c != null; c = c.getCause()) out += " <- " + c.getClass().getName() + ": " + first(c.getMessage());
        }
        Delta x = since(d);
        p(label + " (" + db + ", " + store + "): repository calls " + x.inv + " · prepareStatementCount " + x.sql + " · per call [" + x.inv + "] and [" + x.sql + "] · " + out);
        compare(label, List.of(x.inv), List.of(x.sql));
    }

    static final List<String> NAMES = List.of("Alice", "Brian", "Clara", "Derek", "Elena", "Frank", "Grace", "Henry", "Irene", "James");

    static void evict() throws Exception {
        int stale = 0, again = 0;
        var per = new ArrayList<String>();
        for (String n : NAMES) {
            repo().findAll();
            repo().add(new Customer(n, 1, 100, "VEG"));
            Delta d = mark();
            List<Customer> b = repo().findAll();
            Delta x = since(d);
            boolean st = b.stream().noneMatch(c -> c.name().equals(n));
            Delta d2 = mark();
            repo().findAll();
            Delta y = since(d2);
            if (st) stale++;
            if (y.inv > 0) again++;
            per.add(n + (st ? " stale" : " fresh") + " " + x.inv);
        }
        int rows = new JdbcTemplate(ctx.getBean(DataSource.class)).queryForObject("select count(*) from customer", Integer.class);
        p("evict (" + db + ", " + store + "): ten rounds of a read, add(a new name) and an immediate read: the new name missing (stale) in " + stale + " of 10 rounds");
        p("evict: per round, the immediate read's repository calls: " + per);
        System.err.println("U11-RAW evict (" + store + "): the read after the immediate one reached the repository in " + again + " of 10 rounds (varies run to run - not in the capture)");
        p("evict: rows by JdbcTemplate (a second client) " + rows);
        Cache cache = manager().getCache("customers");
        List<Customer> list = repo().findAll();
        int miss = 0;
        for (int i = 0; i < 50; i++) {
            cache.evictIfPresent(org.springframework.cache.interceptor.SimpleKey.EMPTY);
            cache.put(org.springframework.cache.interceptor.SimpleKey.EMPTY, list);
            Delta d = mark();
            repo().findAll();
            if (since(d).inv > 0) miss++;
        }
        cache.evictIfPresent(org.springframework.cache.interceptor.SimpleKey.EMPTY);
        p("evict: then fifty rounds on the same cache and key through Spring's Cache API - evictIfPresent (immediate by its contract), put(the list), an immediate findAll(): a read right after the put reached the repository in at least one of the fifty: " + (miss > 0 ? "yes" : "no"));
        System.err.println("U11-RAW evict (" + store + "): reads right after a put that reached the repository: " + miss + " of 50 (varies run to run - not in the capture)");
    }

    static void nullv() throws Exception {
        var h = ctx.getBean(HarnessNull.Lookups.class);
        p("nullv: a harness bean, not the anchor's cache - HarnessNull.Lookups; the cache names at the start " + new TreeSet<>(manager().getCacheNames()));
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        String r = "";
        for (int i = 0; i < 2; i++) {
            Delta d = mark();
            r = String.valueOf(h.none());
            Delta x = since(d);
            inv.add(x.inv);
            sql.add(x.sql);
        }
        p("nullv: two calls of @Cacheable(\"h11\") none() (" + db + ", " + store + "): returned " + r + " · per call " + inv + " and " + sql);
        compare("nullv", inv, sql);
    }
}
