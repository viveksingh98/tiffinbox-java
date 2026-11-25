package probe.u08;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * Course 9, unit 08 - the harness's, never TiffinBox's: LABELLED routes under /probe/u08/** only (U07's U07Probe, trimmed and renamed).
 * The second client on H2: JdbcTemplate on TiffinBox's own DataSource, never the cached routes.
 * /probe/u08/row/{name} - the customer row (name, meals per day, price per meal, meal type, version); /probe/u08/count - every customer
 * row; /probe/u08/keys - the idempotency_key table's row count; /probe/u08/plant - the harness's plant page: ten lines of HTML that link
 * one stylesheet on a host that is not this computer (the probe's own external reference), so the seal's judge has a request to refuse.
 */
@RestController
public class U08Probe {
    private static final String PLANT = """
            <!doctype html>
            <html lang="en">
            <head>
            <meta charset="utf-8">
            <title>the harness's plant page</title>
            <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Open+Sans">
            </head>
            <body><p>the harness's plant page: one external stylesheet, never TiffinBox's</p></body>
            </html>
            """;
    private final JdbcTemplate jdbc;

    U08Probe(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/probe/u08/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }

    @GetMapping("/probe/u08/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    @GetMapping("/probe/u08/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u08/plant")
    ResponseEntity<String> plant() {
        return ResponseEntity.ok().contentType(MediaType.TEXT_HTML).body(PLANT);
    }
}
