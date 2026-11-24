package probe.u07;

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
 * Course 9, unit 07 - the harness's, never TiffinBox's: LABELLED reads under /probe/u07/** only (U06's U06Probe, trimmed and renamed).
 * The second client on H2: JdbcTemplate on TiffinBox's own DataSource, never the cached routes.
 * /probe/u07/row/{name} - the customer row (name, meals per day, price per meal, meal type, version); /probe/u07/count - every customer
 * row; /probe/u07/keys - the idempotency_key table's row count; /probe/u07/mapper - the class of every Jackson 3 JsonMapper bean in the
 * context, and of a Jackson 2 ObjectMapper bean if one is there (by class name, so the harness compiles without Jackson 2).
 */
@RestController
public class U07Probe {
    private final JdbcTemplate jdbc;
    private final ApplicationContext ctx;

    U07Probe(JdbcTemplate jdbc, ApplicationContext ctx) {
        this.jdbc = jdbc;
        this.ctx = ctx;
    }

    @GetMapping("/probe/u07/row/{name}")
    List<Map<String, Object>> row(@PathVariable String name) {
        return jdbc.queryForList("SELECT name, meals_per_day, price_per_meal, meal_type, version FROM customer WHERE name = ?", name);
    }

    @GetMapping("/probe/u07/count")
    Map<String, Object> count() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM customer", Integer.class));
    }

    @GetMapping("/probe/u07/keys")
    Map<String, Object> keys() {
        return Map.of("rows", jdbc.queryForObject("SELECT COUNT(*) FROM idempotency_key", Integer.class));
    }

    @GetMapping("/probe/u07/mapper")
    Map<String, Object> mapper() throws ClassNotFoundException {
        var out = new LinkedHashMap<String, Object>();
        var j3 = new TreeSet<String>();
        for (Object b : ctx.getBeansOfType(tools.jackson.databind.json.JsonMapper.class).values()) j3.add(b.getClass().getName());
        out.put("jackson3", j3);
        var j2 = new TreeSet<String>();
        try {
            Class<?> k = Class.forName("com.fasterxml.jackson.databind.ObjectMapper");
            for (Object b : ctx.getBeansOfType(k).values()) j2.add(b.getClass().getName());
            out.put("jackson2_class", "present");
        } catch (ClassNotFoundException e) {
            out.put("jackson2_class", "absent");
        }
        out.put("jackson2_beans", j2);
        return out;
    }
}
