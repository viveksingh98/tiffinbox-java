package probe.u09;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Course 9, unit 09 - the harness's, never TiffinBox's: LABELLED routes under /probe/u09/** only (U08's U08Probe, its plant page left
 * out and renamed). The second client on H2: JdbcTemplate on TiffinBox's own DataSource, never the cached routes.
 * /probe/u09/row/{name} - the customer row; /probe/u09/count - every customer row; /probe/u09/keys - the idempotency_key table's row count;
 * POST /probe/u09/inflight/{key}/{from} - the harness's plant row: an in-flight claim (status 0) under key with from's fingerprint.
 */
@RestController
public class U09Probe {
    private final JdbcTemplate jdbc;

    U09Probe(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/probe/u09/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }

    @GetMapping("/probe/u09/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    /** The harness's plant row (as IdempotencyKeyTest plants one): an in-flight claim under a new key with another row's fingerprint. */
    @PostMapping("/probe/u09/inflight/{key}/{from}")
    Map<String, Object> inflight(@PathVariable String key, @PathVariable String from) {
        return Map.of("rows", jdbc.update("INSERT INTO idempotency_key (idem_key, request_hash, status, claim_token, claimed_at) "
                + "SELECT ?, request_hash, 0, ?, CURRENT_TIMESTAMP FROM idempotency_key WHERE idem_key = ?", key, UUID.randomUUID().toString(), from));
    }

    @GetMapping("/probe/u09/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }
}
