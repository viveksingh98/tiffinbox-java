package probe;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (copied from the S1 probe's Routes.java, trimmed to what unit 04 needs): LABELLED harness routes under /probe/** only.
 * POST /probe/pauses/{name}?days= - a pause added with no key (the harness's route: not in the key filter's URL patterns, so no key is
 * read); /probe/coltype/{table}/{column} - a column's type as the database's
 * INFORMATION_SCHEMA names it; /probe/row/{name} - the second client on H2 (JdbcTemplate on TiffinBox's own DataSource, never the cached /customers routes).
 */
@RestController
public class Routes {
    private final JdbcTemplate jdbc;

    Routes(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @PostMapping("/probe/pauses/{name}")
    Map<String, Object> pause(@PathVariable String name, @RequestParam int days) {
        int n = jdbc.update("INSERT INTO pause (customer_id, days) SELECT id, ? FROM customer WHERE name = ?", days, name);
        var out = new LinkedHashMap<String, Object>();
        out.put("customer", name);
        out.put("days", days);
        out.put("inserted", n);
        return out;
    }

    @GetMapping("/probe/coltype/{table}/{column}")
    Map<String, Object> coltype(@PathVariable String table, @PathVariable String column) {
        return jdbc.queryForMap("SELECT DATA_TYPE AS data_type FROM INFORMATION_SCHEMA.COLUMNS WHERE LOWER(TABLE_NAME) = ? AND LOWER(COLUMN_NAME) = ?",
                table.toLowerCase(), column.toLowerCase());
    }

    @GetMapping("/probe/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }
}
