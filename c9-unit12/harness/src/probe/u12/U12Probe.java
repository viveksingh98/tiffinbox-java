package probe.u12;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * Course 9, unit 12 - the harness's, never TiffinBox's: LABELLED routes under /probe/u12/** only (U11's U11Probe, renamed; the second
 * client). The second client on H2: JdbcTemplate on TiffinBox's own DataSource, never the cached routes.
 * /probe/u12/row/{name} - the customer row; /probe/u12/count - every customer row; /probe/u12/keys - the idempotency_key table's row count;
 */
@RestController
public class U12Probe {
    private final JdbcTemplate jdbc;

    U12Probe(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/probe/u12/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }

    @GetMapping("/probe/u12/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    @GetMapping("/probe/u12/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }
}
