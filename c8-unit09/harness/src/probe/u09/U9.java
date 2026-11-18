package probe.u09;

import com.tiffinbox.CustomerEntityRepository;
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
import org.springframework.cache.interceptor.KeyGenerator;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.SpringVersion;

import javax.sql.DataSource;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;
import java.util.concurrent.Callable;

/**
 * Unit 09's harness: TiffinBox's application class with no web server, Counter (witness 1, calls into Spring Data JPA's repository -
 * unit 08's class, copied) and H09 (a harness bean, not the anchor's cache) beside it, Hibernate's statistics on (witness 2,
 * getPrepareStatementCount(), Course 7's pinned counter). args[0] is a comma-separated list of steps; every line it prints starts
 * with PROBE:
 *   info      the database that answered, the versions, spring.cache.type, the CacheManager beans, the start's own read (its window)
 *   managers  the CacheManager bean's class, the cache h09:all's class and its native cache's class; Redis's connection factory, its
 *             address and its answer to PING when one is on the class path; three calls of all() when the manager is not Redis's
 *   keys      one call each of k0(), k1("a"), k2("a", 1), kName("a"), kGen("a") on one cache, then that cache's native keys
 *   pair      k1("a") then kSpel("a", 9) on the same cache: what each returned, both witnesses, the native entries
 *   bean      the harness bean's class and its advisor list (printed, not interpreted)
 *   self      all() three times through the bean, then (the cache cleared) allViaSelf() three times
 *   pkg       the package-private @Cacheable method, three times;  priv  the private one through a public caller, three times
 *   final     (H09Final, its own source) the public final @Cacheable method, three times
 *   fclass    (FinalOne, its own source) its @Cacheable read, three times
 * In every window the two witnesses' per-call lists are compared; a mismatch prints FAIL and exits 1 (R.375).
 */
public final class U9 {
    private U9() {}

    static ConfigurableApplicationContext ctx;
    static String db = "";
    static boolean ok = true;

    public static void main(String[] args) throws Exception {
        String steps = args[0];
        String[] rest = Arrays.copyOfRange(args, 1, args.length);
        List<Class<?>> src = new ArrayList<>(List.of(Class.forName("com.tiffinbox.web.TiffinBoxApp"), Counter.class, H09.class));
        if (steps.contains("final")) src.add(H09Final.class);
        if (steps.contains("fclass")) src.add(FinalOne.class);
        var app = new SpringApplication(src.toArray(new Class<?>[0]));
        app.setWebApplicationType(WebApplicationType.NONE);
        int code = 0;
        try {
            ctx = app.run(rest);
        } catch (Throwable t) {
            System.out.println("PROBE started: no · " + t.getClass().getName());
            for (Throwable c = t; c != null; c = c.getCause()) {
                String m = String.valueOf(c.getMessage()).split("\n")[0];
                System.out.println("PROBE   its cause chain: " + c.getClass().getName() + ": " + m);
                if (c.getCause() == c) break;
            }
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

    static Statistics stats() {
        return ctx.getBean(EntityManagerFactory.class).unwrap(SessionFactory.class).getStatistics();
    }

    static H09.Reads reads() {
        return ctx.getBean(H09.Reads.class);
    }

    static Map<String, CacheManager> managers() {
        return ctx.getBeansOfType(CacheManager.class);
    }

    static CacheManager manager() {
        return managers().values().iterator().next();
    }

    static String cls(Object o) {
        return o.getClass().getName().replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$0").replaceAll("\\$\\$Lambda.*$", "\\$\\$Lambda");
    }

    static String advisors(Object bean) {
        if (!(bean instanceof Advised a)) return "not Advised (no proxy)";
        var out = new ArrayList<String>();
        for (Advisor ad : a.getAdvisors()) out.add(ad.getClass().getSimpleName() + "(" + cls(ad.getAdvice()) + ")");
        return a.getAdvisors().length + " " + out;
    }

    /** A ConcurrentMapCache's entries, read off its native map: each key as its class = its string form, then -> the value. */
    static String entries(String name) {
        CacheManager cm = manager();
        if (!cm.getCacheNames().contains(name)) return "cache " + name + ": not made yet (0 entries)";
        Cache c = cm.getCache(name);
        if (!(c.getNativeCache() instanceof Map<?, ?> nat)) return "cache " + name + ": native " + c.getNativeCache().getClass().getName();
        var keys = new ArrayList<String>();
        for (var e : nat.entrySet()) keys.add(e.getKey().getClass().getName() + " = " + e.getKey() + " -> " + e.getValue());
        keys.sort(null);
        return "cache " + name + " entries " + nat.size() + " " + keys;
    }

    static void clear(String name) {
        Cache c = manager().getCache(name);
        if (c != null) c.clear();
    }

    /** One window: each call's delta on both witnesses, what each returned; the two lists compared (R.375). */
    static void window(String label, List<Callable<Object>> calls) throws Exception {
        var st = stats();
        long c0 = Counter.CALLS.get(), s0 = st.getPrepareStatementCount();
        var inv = new ArrayList<Long>();
        var sql = new ArrayList<Long>();
        var ret = new ArrayList<String>();
        for (var call : calls) {
            long c = Counter.CALLS.get(), q = st.getPrepareStatementCount();
            ret.add(String.valueOf(call.call()));
            inv.add(Counter.CALLS.get() - c);
            sql.add(st.getPrepareStatementCount() - q);
        }
        p(label + " (" + db + "): repository calls " + (Counter.CALLS.get() - c0) + " · prepareStatementCount " + (st.getPrepareStatementCount() - s0)
                + " · per call " + inv + " and " + sql + " · returned " + ret);
        p(label + ": the two witnesses' per-call lists " + (inv.equals(sql) ? "equal" : "DIFFER"));
        if (!inv.equals(sql)) {
            ok = false;
            p("FAIL R.375: the invocation counter and the statement counter disagree");
        }
    }

    static List<Callable<Object>> times(int n, Callable<Object> c) {
        var l = new ArrayList<Callable<Object>>();
        for (int i = 0; i < n; i++) l.add(c);
        return l;
    }

    static void step(String s) throws Exception {
        switch (s) {
            case "info" -> info();
            case "managers" -> managersStep();
            case "keys" -> keys();
            case "pair" -> {
                clear("h09:keys");
                var r = reads();
                window("pair: k1(\"a\") then kSpel(\"a\", 9), one cache h09:keys", List.of(() -> r.k1("a"), () -> r.kSpel("a", 9)));
                p("pair: then " + entries("h09:keys"));
            }
            case "bean" -> {
                Object r = reads();
                p("bean: the harness bean H09.Reads (a harness bean, not the anchor's cache): its class " + cls(r) + " · advisors (printed, not interpreted) " + advisors(r));
            }
            case "self" -> {
                var r = reads();
                clear("h09:all");
                window("self: all() three times, called from outside the bean", times(3, r::all));
                p("self: then " + entries("h09:all"));
                clear("h09:all");
                p("self: the cache cleared · " + entries("h09:all"));
                window("self: allViaSelf() three times - it calls this.all()", times(3, r::allViaSelf));
                p("self: then " + entries("h09:all"));
            }
            case "pkg" -> {
                var r = reads();
                window("pkg: the package-private @Cacheable pkg(\"k\") three times", times(3, () -> r.pkg("k")));
                p("pkg: then " + entries("h09:pkg"));
            }
            case "priv" -> {
                var r = reads();
                window("priv: the private @Cacheable priv(\"k\") three times, through the public privViaPublic(\"k\")", times(3, () -> r.privViaPublic("k")));
                p("priv: then " + entries("h09:priv"));
            }
            case "final" -> {
                var f = ctx.getBean(H09Final.Fin.class);
                p("final: the harness bean H09Final.Fin (a harness bean, not the anchor's cache): its class " + cls(f) + " · advisors (printed, not interpreted) " + advisors(f));
                window("final: the public final @Cacheable fin(\"k\") three times", times(3, () -> f.fin("k")));
                p("final: then " + entries("h09:fin"));
            }
            case "fclass" -> {
                var f = ctx.getBean(FinalOne.Reads.class);
                p("fclass: the harness bean FinalOne.Reads (a harness bean, not the anchor's cache): its class " + cls(f) + " · advisors (printed, not interpreted) " + advisors(f));
                window("fclass: its @Cacheable read(\"k\") three times", times(3, () -> f.read("k")));
                p("fclass: then " + entries("h09:fc"));
            }
            default -> throw new IllegalArgumentException("no step " + s);
        }
    }

    static void info() {
        p("versions: Spring Boot " + SpringBootVersion.getVersion() + " · Spring Framework " + SpringVersion.getVersion()
                + " · Hibernate " + org.hibernate.Version.getVersionString());
        p("spring.cache.type: " + ctx.getEnvironment().getProperty("spring.cache.type", "unset"));
        var m = managers();
        var desc = new ArrayList<String>();
        m.forEach((k, v) -> desc.add(k + "=" + v.getClass().getName()));
        p("CacheManager beans " + m.size() + " " + desc);
        Object er = ctx.getBean(CustomerEntityRepository.class);
        p("CustomerEntityRepository's bean: a " + (er instanceof Advised ? "Spring AOP proxy (Advised)" : "plain object")
                + " · the counter installed: " + Counter.installed);
        var st = stats();
        p("the start's own read (TiffinBoxServer.start(), @PostConstruct), its own window, from the context's first statement to here ("
                + db + "): repository calls " + Counter.CALLS.get() + " · prepareStatementCount " + st.getPrepareStatementCount());
    }

    static void managersStep() throws Exception {
        CacheManager cm = manager();
        Cache c = cm.getCache("h09:all");
        p("managers: the CacheManager bean " + cm.getClass().getName() + " · getCache(\"h09:all\") " + (c == null ? "null" : c.getClass().getName()
                + " · its native cache " + c.getNativeCache().getClass().getName()));
        Class<?> rcf;
        try {
            rcf = Class.forName("org.springframework.data.redis.connection.RedisConnectionFactory");
        } catch (ClassNotFoundException e) {
            rcf = null;
        }
        if (rcf == null) {
            p("managers: Spring Data Redis on the class path: no");
        } else {
            Object cf = ctx.getBean(rcf);
            Object host = cf.getClass().getMethod("getHostName").invoke(cf), port = cf.getClass().getMethod("getPort").invoke(cf);
            Class<?> rc = Class.forName("org.springframework.data.redis.connection.RedisConnection");
            Object conn = rcf.getMethod("getConnection").invoke(cf);
            String pong, version;
            try {
                pong = String.valueOf(Class.forName("org.springframework.data.redis.connection.RedisConnectionCommands").getMethod("ping").invoke(conn));
                Object server = rc.getMethod("serverCommands").invoke(conn);
                Properties info = (Properties) Class.forName("org.springframework.data.redis.connection.RedisServerCommands").getMethod("info", String.class).invoke(server, "server");
                version = info.getProperty("redis_version");
            } finally {
                rc.getMethod("close").invoke(conn);
            }
            p("managers: Spring Data Redis on the class path: yes · its connection factory " + cf.getClass().getName() + " · " + host + ":" + port
                    + " · PING -> " + pong + " · INFO server: redis_version " + version);
        }
        if (cm.getClass().getName().contains("Redis")) {
            p("managers: no counted window on Redis's manager here (the writer Boot builds over Lettuce is unit 11's measured receipt)");
        } else {
            clear("h09:all");
            var r = reads();
            window("managers: all() three times through " + cm.getClass().getSimpleName(), times(3, r::all));
        }
    }

    static void keys() throws Exception {
        clear("h09:keys");
        var r = reads();
        var kg = ctx.getBean("h09Keys", KeyGenerator.class);
        p("keys: the KeyGenerator bean h09Keys: " + kg);
        window("keys: k0(), k1(\"a\"), k2(\"a\", 1), kName(\"a\"), kGen(\"a\") once each, one cache h09:keys",
                List.of(r::k0, () -> r.k1("a"), () -> r.k2("a", 1), () -> r.kName("a"), () -> r.kGen("a")));
        CacheManager cm = manager();
        var nat = (Map<?, ?>) cm.getCache("h09:keys").getNativeCache();
        var keys = new TreeMap<String, String>();
        for (var e : nat.entrySet()) keys.put(String.valueOf(e.getValue()), e.getKey().getClass().getName() + " = " + e.getKey());
        p("keys: the cache " + cm.getCache("h09:keys").getClass().getName() + " over " + nat.getClass().getName() + " holds " + nat.size() + " entries");
        for (var e : keys.entrySet()) p("keys: native key " + e.getValue() + "   (its value " + e.getKey() + ")");
    }
}
