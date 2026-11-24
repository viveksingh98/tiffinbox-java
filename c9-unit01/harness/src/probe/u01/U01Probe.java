package probe.u01;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeSet;

/**
 * Course 9, unit 01 - the harness's, never TiffinBox's. Two LABELLED read-only routes under /probe/u01/** (U04's U04Probe keys()
 * reader, trimmed to what unit 01 needs; written here because U04's class also carries the hold advice, the order witness and
 * the plants unit 01 does not use):
 * GET /probe/u01/cache - the customers cache's keys (Caffeine's own map, read without touching the cache: S9.29);
 * GET /probe/u01/keys  - the second client on H2: the idempotency_key table's row count (JdbcTemplate on TiffinBox's own
 * DataSource). On PostgreSQL the receipt asks psql in the container instead.
 */
@RestController
public class U01Probe {
    private final JdbcTemplate jdbc;
    private final CacheManager caches;

    U01Probe(JdbcTemplate jdbc, CacheManager caches) {
        this.jdbc = jdbc;
        this.caches = caches;
    }

    @GetMapping("/probe/u01/cache")
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

    @GetMapping("/probe/u01/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }
}
