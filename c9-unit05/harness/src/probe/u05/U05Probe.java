package probe.u05;

import jakarta.json.Json;
import jakarta.json.spi.JsonProvider;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

/**
 * Course 9, unit 05 - the harness's, never TiffinBox's: LABELLED reads under /probe/u05/** only. /probe/u05/cache - the keys of the
 * customers and customer caches, read off Caffeine's own map (never through the cache, so a read changes nothing), and the spec's
 * time to live as Caffeine's policy holds it (the cache keys route's shape is U04's U04Probe /probe/u04/cache, trimmed);
 * /probe/u05/keys - the idempotency_key table's row count (PATCH is not keyed: it must stay 0); /probe/u05/rows/{name} - the row count
 * by name (the second client on H2, JdbcTemplate on TiffinBox's own DataSource); /probe/u05/jsonp - the JSON-P provider a running JVM
 * finds behind jakarta.json.Json and the jar each class came from.
 */
@RestController
public class U05Probe {
    private final JdbcTemplate jdbc;
    private final CacheManager caches;

    U05Probe(JdbcTemplate jdbc, CacheManager caches) {
        this.jdbc = jdbc;
        this.caches = caches;
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

    @GetMapping("/probe/u05/cache")
    Map<String, Object> cache() {
        var out = new LinkedHashMap<String, Object>();
        for (String n : List.of("customers", "customer")) {
            Cache c = caches.getCache(n);
            out.put(n, keys(c));
            if (c != null && c.getNativeCache() instanceof com.github.benmanes.caffeine.cache.Cache<?, ?> cc) {
                out.put(n + ".expireAfterWrite", cc.policy().expireAfterWrite().map(e -> e.getExpiresAfter().toString()).orElse(null));
            }
        }
        return out;
    }

    @GetMapping("/probe/u05/keys")
    Map<String, Object> keyRows() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u05/rows/{name}")
    Map<String, Object> rows(@PathVariable String name) {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer WHERE name = ?", Integer.class, name));
    }

    static String jar(Class<?> k) {
        var src = k.getProtectionDomain().getCodeSource();
        if (src == null || src.getLocation() == null) return "unknown";
        String p = src.getLocation().getPath();
        return p.substring(p.lastIndexOf('/', p.length() - 2) + 1);
    }

    @GetMapping("/probe/u05/jsonp")
    Map<String, Object> jsonp() {
        var out = new LinkedHashMap<String, Object>();
        JsonProvider p = JsonProvider.provider();
        out.put("provider", p.getClass().getName());
        out.put("providerJar", jar(p.getClass()));
        out.put("apiJar", jar(Json.class));
        out.put("mergePatch", Json.createMergePatch(Json.createObjectBuilder().build()).getClass().getName());
        out.put("jsonPatch", Json.createPatch(Json.createArrayBuilder().build()).getClass().getName());
        return out;
    }
}
