package probe.u03;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeSet;

/**
 * Course 9, unit 03 - the harness's route, never TiffinBox's. Four LABELLED routes under /probe/u03/**: the first two are U02's
 * U02Probe routes (copied from U02's harness, which copied them from U01's U01Probe; the path renamed), the third is the S1 probe's
 * /probe/row/{name} (the boundary's instruments/probe-src/Routes.java, the path renamed), the fourth is that file's boom() (the
 * same throw, the path renamed):
 * GET /probe/u03/cache       - the customers cache's keys (Caffeine's own map, read without touching the cache: S9.29);
 * GET /probe/u03/keys        - the second client on H2: the idempotency_key table's row count (JdbcTemplate on TiffinBox's own
 *                              DataSource). On PostgreSQL the receipt asks psql in the container instead;
 * GET /probe/u03/row/{name}  - the second client: how many customer rows carry that name (never the cached routes);
 * GET /probe/u03/boom        - throws an unmapped exception: Boot's /error answers 500 - a harness route, never TiffinBox's.
 */
@RestController
public class U03Probe {
    private final JdbcTemplate jdbc;
    private final CacheManager caches;

    U03Probe(JdbcTemplate jdbc, CacheManager caches) {
        this.jdbc = jdbc;
        this.caches = caches;
    }

    @GetMapping("/probe/u03/cache")
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

    @GetMapping("/probe/u03/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u03/row/{name}")
    Map<String, Object> row(@PathVariable String name) {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer WHERE name = ?", Integer.class, name));
    }

    @GetMapping("/probe/u03/boom")
    Map<String, Object> boom() {
        throw new IllegalStateException("probe: a planted failure (the harness's labelled 500)");
    }
}
