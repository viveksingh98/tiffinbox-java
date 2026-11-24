package probe.u04;

import com.tiffinbox.CustomerAdded;
import jakarta.servlet.http.HttpServletRequest;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.aop.framework.Advised;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.concurrent.ConcurrentMapCache;
import org.springframework.cache.transaction.TransactionAwareCacheDecorator;
import org.springframework.cache.transaction.TransactionAwareCacheManagerProxy;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import java.util.concurrent.TimeUnit;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (BLUE C9-U04's U04Probe, 2026-11-23, its hold's wait made a file watch), on --spring.main.sources only: the hold for the SHIPPED code (RED
 * C9-U04 #10). An advice at position 0 of CustomerRepository's and Pauses' proxies (outside the cache and transaction advice) runs
 * around add: X-Probe-Hold-Where before-write | after-write | before-commit holds until the script creates X-Probe-Hold-File (a
 * 40-second alarm); X-Probe-Fail-After-Write plants an exception after the write. U08's order witness (Course 8 unit 08's three
 * points) and Course 8 unit 27's event-then-evict order print the customers cache at each point. /probe/u04/* reads the key rows, the
 * caches (Caffeine's policy too) and the proxy self-test; a startup line pins the key filter's order against Spring Security's.
 */
@Configuration(proxyBeanMethods = false)
@RestController
public class U04Probe {

    static volatile CacheManager CACHES;

    private final JdbcTemplate jdbc;
    private final CacheManager caches;
    private final ApplicationContext ctx;
    private final PlatformTransactionManager tm;

    U04Probe(JdbcTemplate jdbc, CacheManager caches, ApplicationContext ctx, @Qualifier("transactionManager") PlatformTransactionManager tm) {
        this.jdbc = jdbc;
        this.caches = caches;
        this.ctx = ctx;
        this.tm = tm;
        CACHES = caches;
    }

    static String keys(String name) {
        CacheManager cm = CACHES;
        if (cm == null) return "?";
        Cache c = cm.getCache(name);
        if (c == null) return "absent";
        if (c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) {
            var k = new TreeSet<String>();
            cc.asMap().keySet().forEach(x -> k.add(String.valueOf(x)));
            return k.toString();
        }
        return c.getNativeCache().getClass().getSimpleName();
    }

    static HttpServletRequest request() {
        return RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes a ? a.getRequest() : null;
    }

    static void say(String s) {
        System.out.println(s);
    }

    static void holdUntil(String file, String where) {
        if (file == null) return;
        say("U04HOLD " + where + ": until the script creates " + Path.of(file).getFileName() + " (the harness's hold)");
        Path f = Path.of(file);
        long alarm = System.nanoTime() + 40_000_000_000L;
        try (WatchService ws = f.getFileSystem().newWatchService()) {
            f.getParent().register(ws, StandardWatchEventKinds.ENTRY_CREATE);
            while (!Files.exists(f)) {                     // a file watch, no timed wait: the script's file releases the hold
                long left = alarm - System.nanoTime();
                if (left <= 0) {
                    say("U04HOLD ALARM " + where + ": the file did not appear");
                    return;
                }
                WatchKey k = ws.poll(left, TimeUnit.NANOSECONDS);
                if (k != null) {
                    k.pollEvents();
                    k.reset();
                }
            }
        } catch (IOException e) {
            say("U04HOLD ALARM " + where + ": " + e);
            return;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return;
        }
        say("U04HOLD RELEASED " + where);
    }

    /** The advice: around add only, on the two shipped beans; everything else passes. */
    static final class Hold implements MethodInterceptor {
        private final String bean;

        Hold(String bean) {
            this.bean = bean;
        }

        @Override
        public Object invoke(MethodInvocation inv) throws Throwable {
            if (!inv.getMethod().getName().equals("add")) return inv.proceed();
            HttpServletRequest req = request();
            String where = req == null ? null : req.getHeader("X-Probe-Hold-Where");
            String file = req == null ? null : req.getHeader("X-Probe-Hold-File");
            String key = req == null ? null : req.getHeader("Idempotency-Key");
            String tag = bean + ".add (key " + key + ")";
            if ("before-write".equals(where)) holdUntil(file, tag + " before the write, inside phase 2");
            Object r = inv.proceed();
            say("U08ORDER " + tag + " returned: transaction active " + TransactionSynchronizationManager.isActualTransactionActive()
                    + " · customers cache " + keys("customers"));
            if (req != null && req.getHeader("X-Probe-Fail-After-Write") != null) {
                say("U04PLANT " + tag + ": an exception after the write (the harness's)");
                throw new IllegalStateException("probe: a planted failure after the write (the harness's)");
            }
            if ("after-write".equals(where)) holdUntil(file, tag + " after the write, inside phase 2");
            if ("before-commit".equals(where) && TransactionSynchronizationManager.isSynchronizationActive()) {
                TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                    @Override
                    public void beforeCommit(boolean readOnly) {
                        holdUntil(file, tag + " before the commit (the stored answer's UPDATE already sent)");
                    }
                });
            }
            return r;
        }
    }

    @Bean
    static BeanPostProcessor u04Hold() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String name) {
                String c = AopUtils.getTargetClass(bean).getSimpleName();
                if ((c.equals("CustomerRepository") || c.equals("Pauses")) && bean instanceof Advised a) {
                    a.addAdvice(0, new Hold(c));
                    say("U04HOLD advice added at position 0 of " + name + " (" + c + "): advisors now " + a.getAdvisors().length);
                }
                return bean;
            }
        };
    }

    @EventListener
    void inside(CustomerAdded e) {
        say("U08ORDER the CustomerAdded event, inside add's transaction: transaction active "
                + TransactionSynchronizationManager.isActualTransactionActive() + " · customers cache " + keys("customers"));
    }

    @TransactionalEventListener
    void afterCommit(CustomerAdded e) {
        say("U08ORDER the CustomerAdded event after the commit (the feed's phase): customers cache " + keys("customers"));
    }

    @Bean
    ApplicationRunner u04Order(ApplicationContext ctx) {
        return a -> {
            var orders = new TreeMap<String, Integer>();
            ctx.getBeansOfType(FilterRegistrationBean.class).forEach((n, r) -> orders.put(n, r.getOrder()));
            orders.forEach((n, o) -> say("FILTER-ORDER registration " + n + " " + o));
            int k = ctx.getBean("idempotencyKeyFilter", FilterRegistrationBean.class).getOrder();
            int sec;
            String src;
            try {
                Class<?> c = Class.forName("org.springframework.boot.security.autoconfigure.web.servlet.SecurityFilterProperties");
                sec = c.getField("DEFAULT_FILTER_ORDER").getInt(null);
                src = "SecurityFilterProperties.DEFAULT_FILTER_ORDER, read from the class path";
            } catch (ClassNotFoundException e) {
                sec = -100;
                src = "Boot's documented default -100 (SecurityFilterProperties is not on this class path)";
            }
            say("FILTER-ORDER CHECK the key filter's order " + k + (k > sec ? " > " : " <= ") + sec + " (" + src + "): "
                    + (k > sec ? "PASS" : "FAIL"));
            say("CACHE the CacheManager bean: " + ctx.getBean(CacheManager.class).getClass().getName());
        };
    }

    @GetMapping("/probe/u04/keys")
    List<Map<String, Object>> rows() {
        return jdbc.queryForList("SELECT idem_key, status, claim_token IS NOT NULL AS claimed, location FROM idempotency_key ORDER BY idem_key");
    }

    @GetMapping("/probe/u04/pauses")
    Map<String, Object> pauses() {
        return jdbc.queryForMap("SELECT COUNT(*) AS pauses, COALESCE(SUM(days), 0) AS days FROM pause");
    }

    @GetMapping("/probe/u04/cache")
    Map<String, Object> cache() {
        var out = new LinkedHashMap<String, Object>();
        out.put("manager", caches.getClass().getSimpleName()
                + (caches instanceof TransactionAwareCacheManagerProxy ? " (target kept: Boot's)" : ""));
        out.put("names", new TreeSet<>(caches.getCacheNames()));
        out.put("unlisted", String.valueOf(caches.getCache("nope")));
        for (String n : List.of("customers", "customer")) {
            Cache c = caches.getCache(n);
            var m = new LinkedHashMap<String, Object>();
            m.put("decorator", c == null ? "absent" : c.getClass().getSimpleName());
            if (c != null && c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) {
                m.put("keys", keys(n));
                m.put("maximumSize", cc.policy().eviction().map(e -> e.getMaximum()).orElse(null));
                m.put("expireAfterWrite", cc.policy().expireAfterWrite().map(e -> e.getExpiresAfter().toString()).orElse(null));
                m.put("recordStats", cc.policy().isRecordingStats());
            }
            out.put(n, m);
        }
        return out;
    }

    @PostMapping("/probe/u04/cache/clear")
    Map<String, Object> clear() {
        Cache c = caches.getCache("customers");
        if (c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) cc.invalidateAll();
        return Map.of("customers", keys("customers"));
    }

    /** RED C9-U04 #7: the BPP against a transaction-aware RedisCacheManager (never connected), and two nested decorators measured. */
    @GetMapping("/probe/u04/txcache-selftest")
    Map<String, Object> selftest() {
        var out = new LinkedHashMap<String, Object>();
        BeanPostProcessor bpp = ctx.getBean("transactionAwareCacheManager", BeanPostProcessor.class);
        LettuceConnectionFactory never = new LettuceConnectionFactory();
        RedisCacheManager aware = RedisCacheManager.builder(RedisCacheWriter.nonLockingRedisCacheWriter(never)).transactionAware().build();
        RedisCacheManager plain = RedisCacheManager.builder(RedisCacheWriter.nonLockingRedisCacheWriter(never)).build();
        Object a = bpp.postProcessAfterInitialization(aware, "plantedAwareRedis");
        Object p = bpp.postProcessAfterInitialization(plain, "plantedPlainRedis");
        out.put("redis transactionAware(): isTransactionAware", aware.isTransactionAware());
        out.put("redis transactionAware() through the BPP", a == aware ? "returned unchanged (not wrapped)" : "WRAPPED: " + a.getClass().getSimpleName());
        out.put("redis plain through the BPP", p == plain ? "returned unchanged" : "wrapped once: " + p.getClass().getSimpleName()
                + (p instanceof TransactionAwareCacheManagerProxy ? "" : " ?"));
        ConcurrentMapCache base1 = new ConcurrentMapCache("once");
        ConcurrentMapCache base2 = new ConcurrentMapCache("twice");
        Cache once = new TransactionAwareCacheDecorator(base1);
        Cache twice = new TransactionAwareCacheDecorator(new TransactionAwareCacheDecorator(base2));
        base1.put("k", "v");
        base2.put("k", "v");
        new TransactionTemplate(tm).executeWithoutResult(s -> {
            once.clear();
            twice.clear();
            out.put("inside the transaction: once / twice", (base1.get("k") != null) + " / " + (base2.get("k") != null));
        });
        out.put("after the commit, the entry still there: one decorator / two nested", (base1.get("k") != null) + " / " + (base2.get("k") != null));
        return out;
    }
}
