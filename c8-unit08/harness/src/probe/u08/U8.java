package probe.u08;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerAdded;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.CustomerRepository;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.SessionFactory;
import org.hibernate.stat.Statistics;
import org.springframework.aop.Advisor;
import org.springframework.aop.framework.Advised;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringBootVersion;
import org.springframework.boot.WebApplicationType;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.context.ApplicationListener;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.PayloadApplicationEvent;
import org.springframework.core.SpringVersion;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import javax.sql.DataSource;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Unit 08's harness: TiffinBox's application class with no web server, Counter (witness 1, calls into Spring Data JPA's repository)
 * beside it, and Hibernate's statistics on (witness 2, getPrepareStatementCount(), Course 7's pinned counter). args[0] is a
 * comma-separated list of steps; every line it prints starts with PROBE:
 *   info    the database that answered, the versions, the CacheManager beans, the caches and their classes, both beans' classes
 *           and advisor lists - and the start's own read, its own window (TiffinBoxServer.start(), @PostConstruct)
 *   hits    five calls of CustomerRepository.findAll() through the context's bean, one window: both witnesses per call
 *   clear   the customers cache cleared (cacheManager.getCache("customers").clear()), then two calls
 *   evict   one call (the cache filled), add(Emma) - @CacheEvict(allEntries = true) - then two calls; the rows read back by a second client (JdbcTemplate)
 *   order   add(Oliver) with a listener on CustomerAdded (published inside add's transaction): the cache's entries inside the
 *           transaction, after its commit (and a second thread's findAll() there), and after add returned; then one call
 *   health  the kitchen's health (KitchenHealthIndicator, the readiness group's) with the customer table renamed away by JdbcTemplate:
 *           with what the cache holds, then with the customers cache cleared (after/ only) - the last step of a JVM
 *   put     the harness bean HarnessPuts.Customers (needs it as a source): three @CachePut calls, then a @Cacheable read
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U8 {
    private U8() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;
    static volatile boolean listening;
    static final List<String> ORDER = new ArrayList<>();

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class));
        if (steps.contains("put")) src.add(HarnessPuts.class);
        var app = new SpringApplication(src.toArray(new Class<?>[0]));
        app.setWebApplicationType(WebApplicationType.NONE);
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
            p("started: yes · the database that answered: " + db);
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

    static Map<String, CacheManager> managers() {
        return ctx.getBeansOfType(CacheManager.class);
    }

    static String name(Object o) {
        return o.getClass().getName().replaceAll("\\$\\$Lambda.*$", "\\$\\$Lambda");
    }

    static String advisors(Object bean) {
        if (!(bean instanceof Advised a)) return "not Advised (no proxy)";
        var out = new ArrayList<String>();
        for (Advisor ad : a.getAdvisors()) out.add(ad.getClass().getSimpleName() + "(" + name(ad.getAdvice()) + ")");
        return a.getAdvisors().length + " " + out;
    }

    /** The customers cache as the manager holds it - without creating it (a ConcurrentMapCacheManager makes a cache on request). */
    static String entries() {
        var m = managers();
        if (m.isEmpty()) return "no CacheManager bean";
        CacheManager cm = m.values().iterator().next();
        if (!cm.getCacheNames().contains("customers")) return "cache names " + cm.getCacheNames() + " (no customers cache yet)";
        Cache c = cm.getCache("customers");
        var nat = (Map<?, ?>) c.getNativeCache();
        var keys = new ArrayList<String>();
        for (Object k : nat.keySet()) keys.add(k.getClass().getName() + " = " + k);
        return "customers cache entries " + nat.size() + " " + keys;
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "info" -> info();
            case "hits" -> calls("hits: five calls of CustomerRepository.findAll()", 5);
            case "clear" -> {
                managers().values().iterator().next().getCache("customers").clear();
                p("clear: cacheManager.getCache(\"customers\").clear() · then " + entries());
                calls("clear: the next two calls", 2);
            }
            case "evict" -> evict();
            case "order" -> order();
            case "put" -> put();
            case "health" -> health();
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static void info() throws Exception {
        String flyway;
        try (InputStream in = U8.class.getClassLoader().getResourceAsStream("org/flywaydb/core/internal/version.txt")) {
            flyway = new String(in.readAllBytes(), StandardCharsets.UTF_8).trim();
        }
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Spring Data JPA " + jarVersion(org.springframework.data.jpa.repository.JpaRepository.class)
                + " · Spring Data JDBC " + jarVersion(org.springframework.data.jdbc.core.JdbcAggregateTemplate.class)
                + " · Hibernate " + org.hibernate.Version.getVersionString() + " · Flyway (version.txt) " + flyway);
        var m = managers();
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc + " (" + db + ")");
        Object r = repo();
        p("CustomerRepository's bean class: " + r.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$0")
                + " · advisors " + advisors(r));
        Object er = ctx.getBean(CustomerEntityRepository.class);
        p("CustomerEntityRepository's bean: a " + (er instanceof Advised ? "Spring AOP proxy (Advised)" : "plain object")
                + " · the counter installed: " + Counter.installed);
        p("CustomerEntityRepository's advisors (printed, not interpreted): " + advisors(er));
        var st = stats();
        p("the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here ("
                + db + "): repository calls " + Counter.CALLS.get() + " · prepareStatementCount " + st.getPrepareStatementCount()
                + " · " + entries());
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
        p(label + ": the two witnesses' per-call lists " + (inv.equals(sql) ? "equal" : "DIFFER") + " · " + entries());
        if (!inv.equals(sql)) {
            ok = false;
            p("FAIL R.375: the invocation counter and the statement counter disagree");
        }
    }

    static int count() {
        return new JdbcTemplate(ctx.getBean(DataSource.class)).queryForObject("select count(*) from customer", Integer.class);
    }

    static void evict() throws Exception {
        var st = stats();
        calls("evict: the read that fills the cache", 1);
        p("evict: before add, " + entries() + " · rows by JdbcTemplate (a second client, the DataSource's own connection, not through the cache) " + count());
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        repo().add(new Customer("Emma", 2, 110, "VEG"));
        p("evict: add(Emma) (" + db + "): repository calls " + (Counter.CALLS.get() - c0) + " · prepareStatementCount " + (st.getPrepareStatementCount() - s0)
                + " · then " + entries());
        calls("evict: the next two calls", 2);
        p("evict: rows by JdbcTemplate (the second client) " + count());
    }

    static void order() throws Exception {
        AtomicReference<String> seen = new AtomicReference<>("");
        ctx.addApplicationListener((ApplicationListener<PayloadApplicationEvent<?>>) e -> {
            if (!listening || !(e.getPayload() instanceof CustomerAdded)) return;
            ORDER.add("inside add's transaction (a listener on CustomerAdded): transaction active "
                    + TransactionSynchronizationManager.isActualTransactionActive() + " · " + entries());
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    var t = new Thread(() -> {
                        try {
                            long c = Counter.CALLS.get(), q = stats().getPrepareStatementCount();
                            int rows = repo().findAll().size();
                            seen.set("a second thread's findAll() there: rows " + rows + " · repository calls " + (Counter.CALLS.get() - c)
                                    + " · prepareStatementCount " + (stats().getPrepareStatementCount() - q));
                        } catch (Exception x) {
                            seen.set("a second thread's findAll() threw " + x.getClass().getName());
                        }
                    });
                    t.start();
                    try {
                        t.join();
                    } catch (InterruptedException x) {
                        Thread.currentThread().interrupt();
                    }
                    ORDER.add("after the commit, add not yet returned (afterCommit): " + entries() + " · rows by JdbcTemplate " + count() + " · " + seen.get());
                }
            });
        });
        repo().findAll();
        p("order: before add, " + entries() + " · rows by JdbcTemplate " + count());
        listening = true;
        repo().add(new Customer("Oliver", 1, 130, "NON_VEG"));
        listening = false;
        for (String o : ORDER) p("order (" + db + "): " + o);
        p("order (" + db + "): after add returned: " + entries());
        calls("order: the next call", 1);
    }

    static String kitchen() {
        var h = ((org.springframework.boot.health.contributor.HealthIndicator) ctx.getBean("kitchenHealthIndicator")).health();
        return h.getStatus() + " " + new java.util.TreeMap<>(h.getDetails());
    }

    static void health() throws Exception {
        p("health (" + db + "): the kitchen before, " + entries() + ": " + kitchen());
        new JdbcTemplate(ctx.getBean(DataSource.class)).execute("alter table customer rename to customer_gone");
        p("health (" + db + "): JdbcTemplate: alter table customer rename to customer_gone - then the kitchen, " + entries() + ": " + kitchen());
        var m = managers();
        if (!m.isEmpty()) {
            m.values().iterator().next().getCache("customers").clear();
            p("health (" + db + "): the customers cache cleared - then the kitchen, " + entries() + ": " + kitchen());
        }
    }

    static void put() throws Exception {
        var h = ctx.getBean(HarnessPuts.Customers.class);
        var st = stats();
        p("put: a harness bean, not the anchor's cache - HarnessPuts.Customers, " + h.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$0"));
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        h.put(new Customer("Ravi", 1, 120, "VEG"));
        h.put(new Customer("Ravi", 2, 120, "VEG"));
        h.put(new Customer("Ravi", 3, 120, "VEG"));
        CacheManager cm = managers().values().iterator().next();
        var nat = (Map<?, ?>) cm.getCache("customer").getNativeCache();
        p("put: three @CachePut calls (" + db + "): its method ran " + HarnessPuts.Customers.PUTS.get() + " · repository calls " + (Counter.CALLS.get() - c0)
                + " · prepareStatementCount " + (st.getPrepareStatementCount() - s0) + " · the customer cache (" + cm.getCache("customer").getClass().getName()
                + ", native " + nat.getClass().getName() + ") holds " + nat);
        long c1 = Counter.CALLS.get(), s1 = st.getPrepareStatementCount();
        Customer got = h.byName("Ravi");
        p("put: then @Cacheable byName(\"Ravi\") on the same cache and key (" + db + "): its method ran " + HarnessPuts.Customers.READS.get()
                + " · repository calls " + (Counter.CALLS.get() - c1) + " · prepareStatementCount " + (st.getPrepareStatementCount() - s1) + " · returned " + got);
        p("put: the anchor's database row for Ravi by JdbcTemplate: meals_per_day "
                + new JdbcTemplate(ctx.getBean(DataSource.class)).queryForObject("select meals_per_day from customer where name = 'Ravi'", Integer.class));
    }
}
