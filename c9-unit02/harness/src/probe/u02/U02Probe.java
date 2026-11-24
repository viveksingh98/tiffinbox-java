package probe.u02;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeSet;

/**
 * Course 9, unit 02 - the harness's, never TiffinBox's. Three LABELLED read-only routes under /probe/u02/**: the first two are
 * U01's U01Probe routes (copied from U01's harness, the path renamed), the third is the S1 probe's feed reader (its Routes.java
 * feed(), rewritten to find the bean by its class):
 * GET /probe/u02/cache - the customers cache's keys (Caffeine's own map, read without touching the cache: S9.29);
 * GET /probe/u02/keys  - the second client on H2: the idempotency_key table's row count (JdbcTemplate on TiffinBox's own
 * DataSource). On PostgreSQL the receipt asks psql in the container instead;
 * GET /probe/u02/feed  - CustomerFeed's listener count. CustomerFeed is package-private and final: found by its class name and
 * read by reflection (its own listeners() method, the one FeedTest calls), never changed.
 */
@RestController
public class U02Probe {
    private final JdbcTemplate jdbc;
    private final CacheManager caches;
    private final ApplicationContext ctx;

    U02Probe(JdbcTemplate jdbc, CacheManager caches, ApplicationContext ctx) {
        this.jdbc = jdbc;
        this.caches = caches;
        this.ctx = ctx;
    }

    @GetMapping("/probe/u02/cache")
    Map<String, Object> cache() {
        var out = new LinkedHashMap<String, Object>();
        Cache c = caches.getCache("customers");
        if (c != null && c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) {
            var k = new TreeSet<String>();
            cc.asMap().keySet().forEach(x -> k.add(String.valueOf(x)));
            out.put("customers", k.toString());
        } else {
            out.put("customers", c == null ? "absent" : c.getNativeCache().getClass().getSimpleName());
        }
        return out;
    }

    @GetMapping("/probe/u02/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u02/feed")
    Map<String, Object> feed() throws ReflectiveOperationException {
        Class<?> k = Class.forName("com.tiffinbox.web.CustomerFeed");
        Object f = ctx.getBean(k);
        java.lang.reflect.Method m = k.getDeclaredMethod("listeners");
        m.setAccessible(true);
        return Map.of("listeners", m.invoke(f));
    }
}
