package probe.u11;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * Course 9, unit 11 - the harness's, never TiffinBox's: LABELLED routes under /probe/u11/** only (U10's U10Probe, renamed; the second
 * client). The second client on H2: JdbcTemplate on TiffinBox's own DataSource, never the cached routes.
 * /probe/u11/row/{name} - the customer row; /probe/u11/count - every customer row; /probe/u11/keys - the idempotency_key table's row count;
 */
@RestController
public class U11Probe {
    private final JdbcTemplate jdbc;

    U11Probe(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/probe/u11/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }

    @GetMapping("/probe/u11/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    @GetMapping("/probe/u11/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }
}
