package probe.u06;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

/**
 * Course 9, unit 06 - the harness's, never TiffinBox's: LABELLED reads under /probe/u06/** only (U05's U05Probe, trimmed and renamed).
 * /probe/u06/cache - the keys of the customers and customer caches, read off Caffeine's own map (never through the cache, so a read
 * changes nothing); /probe/u06/keys - the idempotency_key table's row count; /probe/u06/rows/{name} - the customer row count by name;
 * /probe/u06/count - every customer row; /probe/u06/pauses/{name} - the pause rows of the customer of that name today, by what the
 * pause table points at (customer_id, a number - not the name); /probe/u06/feed - CustomerFeed's listener count, by reflection on its own
 * listeners() method (U02's U02Probe feed(), copied). The second client on H2: JdbcTemplate on TiffinBox's own DataSource.
 */
@RestController
public class U06Probe {
    private final JdbcTemplate jdbc;
    private final CacheManager caches;
    private final ApplicationContext ctx;

    U06Probe(JdbcTemplate jdbc, CacheManager caches, ApplicationContext ctx) {
        this.jdbc = jdbc;
        this.caches = caches;
        this.ctx = ctx;
    }

    static String keys(Cache c) {
        if (c == null) return "absent";
        if (c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) {
            var k = new TreeSet<String>();
            cc.asMap().keySet().forEach(x -> k.add(String.valueOf(x)));
            return k.toString();
        }
        return c.getNativeCache().getClass().getSimpleName();
    }

    @GetMapping("/probe/u06/cache")
    Map<String, Object> cache() {
        var out = new LinkedHashMap<String, Object>();
        for (String n : List.of("customers", "customer")) out.put(n, keys(caches.getCache(n)));
        return out;
    }

    @GetMapping("/probe/u06/keys")
    Map<String, Object> keyRows() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u06/rows/{name}")
    Map<String, Object> rows(@PathVariable String name) {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer WHERE name = ?", Integer.class, name));
    }

    @GetMapping("/probe/u06/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    @GetMapping("/probe/u06/pauses/{name}")
    Map<String, Object> pauses(@PathVariable String name) {
        var out = new LinkedHashMap<String, Object>();
        out.put("name", name);
        out.put("pauses", jdbc.queryForList("SELECT p.id, p.customer_id, p.days FROM pause p JOIN customer c ON c.id = p.customer_id WHERE c.name = ? ORDER BY p.id", name));
        return out;
    }

    @GetMapping("/probe/u06/feed")
    Map<String, Object> feed() throws ReflectiveOperationException {
        Class<?> k = Class.forName("com.tiffinbox.web.CustomerFeed");
        Object f = ctx.getBean(k);
        java.lang.reflect.Method m = k.getDeclaredMethod("listeners");
        m.setAccessible(true);
        return Map.of("listeners", m.invoke(f));
    }
}
