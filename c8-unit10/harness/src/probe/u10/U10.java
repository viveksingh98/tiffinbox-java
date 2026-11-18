package probe.u10;

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
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.io.InputStream;
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

/**
 * Unit 10's harness: TiffinBox's application class WITH its web server (the port from --tiffinbox.port), Counter (witness 1, calls
 * into Spring Data JPA's repository, copied from unit 08's harness) beside it, Hibernate's statistics on (witness 2,
 * getPrepareStatementCount(), Course 7's pinned counter), and Caffeine's own stats() as a third witness, never the only one. args[0]
 * is a comma-separated list of steps; every line it prints starts with PROBE:
 *   info    the database that answered, the versions, the cache settings the environment holds, the CacheManager beans, the cache
 *           names at the start and each cache's class and native class - and the start's own read, its own window, with
 *           Caffeine's stats and the entry at that point
 *   http    GET /dashboard, /actuator/caches, /actuator/metrics and /actuator/prometheus over HTTP (java.net.http, 127.0.0.1): the
 *           status codes
 *   reads   five calls of CustomerRepository.findAll() through the context's bean, one window: both witnesses per call; then
 *           Caffeine's stats, its estimatedSize and keys (after cleanUp())
 *   scrape  GET /actuator/prometheus: its status, its cache_ lines for the customers cache (printed, sorted) and their count
 *   add     add(Emma) - @CacheEvict(allEntries = true) - then one call; the rows read back by a second client (JdbcTemplate);
 *           Caffeine's stats after it
 *   names   the harness's own caches (HarnessCaches, a second source - a harness bean, not the anchor's cache): the names at the
 *           start, getCache("stampede"), two calls of its @Cacheable("h10") method, one call of its @Cacheable("unnamed") method
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U10 {
    private U10() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;
    static String port = "";

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class));
        if (steps.contains("names")) src.add(HarnessCaches.class);
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
            p("started: yes · the database that answered: " + db + " · a web server: " + (port != null ? "yes" : "no"));
            for (String s : steps.split(",")) step(s);
        } catch (Throwable t) {
            code = 1;
            p("a step threw: " + t.getClass().getName() + ": " + t.getMessage());
        }
        if (!ok) code = 1;
        ctx.close();
        System.out.println("PROBE <<< exit " + code);
        System.exit(code);
    }

    static void p(String s) {
        System.out.println("PROBE " + s);
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

    /** The customers cache's Caffeine cache, without making one (with no names given, the manager makes a cache on request). */
    @SuppressWarnings("unchecked")
    static com.github.benmanes.caffeine.cache.Cache<Object, Object> nat() {
        CacheManager cm = manager();
        if (!cm.getCacheNames().contains("customers")) return null;
        return (com.github.benmanes.caffeine.cache.Cache<Object, Object>) cm.getCache("customers").getNativeCache();
    }

    static String caffeine(String when) {
        var n = nat();
        if (n == null) return when + ": no customers cache yet (cache names " + manager().getCacheNames() + ")";
        n.cleanUp();
        var keys = new ArrayList<String>();
        for (Object k : n.asMap().keySet()) keys.add(k.getClass().getName() + " = " + k);
        return when + ": Caffeine's stats() " + n.stats() + " · estimatedSize " + n.estimatedSize() + " (after cleanUp()) · keys " + keys;
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
            case "http" -> {
                for (String path : List.of("/dashboard", "/actuator/caches", "/actuator/metrics", "/actuator/prometheus"))
                    p("http (" + db + "): GET " + path + " -> " + get(path));
            }
            case "reads" -> {
                calls("reads: five calls of CustomerRepository.findAll()", 5);
                p(caffeine("reads: after the five calls (" + db + ")"));
            }
            case "scrape" -> scrape("scrape");
            case "add" -> add();
            case "names" -> names();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U10.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var env = ctx.getEnvironment();
        p("the environment: spring.cache.type " + env.getProperty("spring.cache.type", "unset")
                + " · spring.cache.cache-names " + env.getProperty("spring.cache.cache-names", "unset")
                + " · spring.cache.caffeine.spec " + env.getProperty("spring.cache.caffeine.spec", "unset")
                + " · management.endpoints.web.exposure.include " + env.getProperty("management.endpoints.web.exposure.include", "unset"));
        Map<String, CacheManager> m = ctx.getBeansOfType(CacheManager.class);
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc + " (" + db + ")");
        CacheManager cm = manager();
        p("the cache names at the start, getCacheNames(): " + cm.getCacheNames());
        for (String n : cm.getCacheNames()) {
            Cache c = cm.getCache(n);
            p("cache " + n + ": " + c.getClass().getName() + " · native " + c.getNativeCache().getClass().getName());
        }
        Object er = ctx.getBean(CustomerEntityRepository.class);
        p("CustomerEntityRepository's bean: a " + (er instanceof org.springframework.aop.framework.Advised ? "Spring AOP proxy (Advised)" : "plain object")
                + " · the counter installed: " + Counter.installed);
        var st = stats();
        var n = nat();
        p("the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here ("
                + db + "): repository calls " + Counter.CALLS.get() + " · prepareStatementCount " + st.getPrepareStatementCount()
                + " · " + (n == null ? "no customers cache yet (cache names " + cm.getCacheNames() + ")"
                : "Caffeine's stats() " + n.stats() + " · estimatedSize " + n.estimatedSize() + " · the list's entry (SimpleKey []) present " + n.asMap().containsKey(org.springframework.cache.interceptor.SimpleKey.EMPTY)));
    }

    /** One window: n calls of findAll(), each call's delta on both witnesses; the lists compared. */
    static void calls(String label, int n) throws Exception {
        var st = stats();
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        int rows = -1;
        for (int i = 0; i < n; i++) {
            long c = Counter.CALLS.get(), q = st.getPrepareStatementCount();
            rows = repo().findAll().size();
            inv.add(Counter.CALLS.get() - c);
            sql.add(st.getPrepareStatementCount() - q);
        }
        p(label + " (" + db + "): repository calls " + (Counter.CALLS.get() - c0) + " · prepareStatementCount " + (st.getPrepareStatementCount() - s0)
                + " · per call " + inv + " and " + sql + " · rows " + rows);
        p(label + ": the two witnesses' per-call lists " + (inv.equals(sql) ? "equal" : "DIFFER"));
        if (!inv.equals(sql)) {
            ok = false;
            p("FAIL R.375: the invocation counter and the statement counter disagree");
        }
    }

    static void scrape(String label) throws Exception {
        String code = get("/actuator/prometheus");
        var mine = new TreeSet<String>();
        int all = 0;
        for (String l : last.split("\n")) {
            if (l.startsWith("cache_")) {
                all++;
                if (l.contains("cache=\"customers\"")) mine.add(l);
            }
        }
        p(label + " (" + db + "): GET /actuator/prometheus -> " + code + " · cache_ lines " + all + " · cache_ lines for customers " + mine.size());
        for (String l : mine) p(label + " (" + db + "): prometheus " + l);
    }

    static int count() {
        return new JdbcTemplate(ctx.getBean(DataSource.class)).queryForObject("select count(*) from customer", Integer.class);
    }

    static void add() throws Exception {
        var st = stats();
        p("add: before, rows by JdbcTemplate (a second client, the DataSource's own connection, not through the cache) " + count());
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        repo().add(new Customer("Emma", 2, 110, "VEG"));
        p("add: add(Emma) (" + db + "): repository calls " + (Counter.CALLS.get() - c0) + " · prepareStatementCount " + (st.getPrepareStatementCount() - s0));
        calls("add: the next call", 1);
        p("add: rows by JdbcTemplate (the second client) " + count());
        p(caffeine("add: after add and the next call (" + db + ")"));
        scrape("add: then");
    }

    static void names() throws Exception {
        CacheManager cm = manager();
        p("names: a harness bean, not the anchor's cache - HarnessCaches.Caches; the cache names at the start " + cm.getCacheNames());
        p("names: getCache(\"stampede\") -> " + cm.getCache("stampede"));
        var h = ctx.getBean(HarnessCaches.Caches.class);
        var st = stats();
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        for (int i = 0; i < 2; i++) {
            long c = Counter.CALLS.get(), q = st.getPrepareStatementCount();
            h.named();
            inv.add(Counter.CALLS.get() - c);
            sql.add(st.getPrepareStatementCount() - q);
        }
        p("names: two calls of @Cacheable(\"h10\") (" + db + "): its method ran " + HarnessCaches.Caches.RUNS.get() + " · repository calls " + (Counter.CALLS.get() - c0)
                + " · per call " + inv + " and " + sql + " · the two lists " + (inv.equals(sql) ? "equal" : "DIFFER"));
        if (!inv.equals(sql)) ok = false;
        try {
            h.unnamed();
            p("names: one call of @Cacheable(\"unnamed\") (" + db + "): returned, no exception");
        } catch (Exception x) {
            p("names: one call of @Cacheable(\"unnamed\") (" + db + "): threw " + x.getClass().getName() + ": "
                    + x.getMessage().replaceAll(" for Builder\\[.*$", " for Builder[…]"));
        }
    }
}
