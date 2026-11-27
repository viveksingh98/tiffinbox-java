// THE HARNESS'S ENTITY-BOUND ROUTE (Course 9 unit 22's evidence, labelled, R.397) - adapted from the S4 probe's ProbeS4.java
// bind route (:193-:199) by a named diff: the same path and PROBE-BIND lines, plus a companion read of every customer row
// (D19) and the running mapper's FAIL_ON_UNKNOWN_PROPERTIES read back at start. Joined ONLY by --spring.main.sources=probe22.Bind.
// Never shipped: no jar, no module.
package probe22;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.json.JsonMapper;

@Configuration
public class Bind {

    // the route is the nested @RestController below: a member class of this configuration, registered with it

    @RestController
    static class BindRoute {
        private final CustomerEntityRepository customers;
        private final JsonMapper json;

        BindRoute(CustomerEntityRepository customers, JsonMapper json) {
            this.customers = customers;
            this.json = json;
        }

        @EventListener(ApplicationReadyEvent.class)
        void readBack() {
            System.out.println("PROBE-KEY FAIL_ON_UNKNOWN_PROPERTIES=" + json.isEnabled(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
                    + " (Boot's jacksonJsonMapper, " + json.getClass().getName() + ", Jackson " + json.version() + ")");
        }

        @PutMapping("/probe/v1/customers/{name}/bind")
        ResponseEntity<Map<String, Object>> bind(@PathVariable String name, @RequestBody String body) {
            CustomerEntity e = customers.findByName(name).orElse(null);
            if (e == null) return ResponseEntity.notFound().build();
            Long before = e.getVersion();
            try {
                json.readerForUpdating(e).readValue(body);
                System.out.println("PROBE-BIND after the read: version=" + e.getVersion() + " (was " + before + ") createdAt=" + e.getCreatedAt() + " mealsPerDay=" + e.getMealsPerDay() + " id=" + e.getId());
                CustomerEntity saved = customers.saveAndFlush(e);
                CustomerEntity back = customers.findById(saved.getId()).orElseThrow();
                return ResponseEntity.ok(Map.of("versionBefore", before, "versionAfterSave", saved.getVersion(), "mealsPerDay", back.getMealsPerDay(),
                        "createdAt", String.valueOf(back.getCreatedAt())));
            } catch (Exception x) {
                System.out.println("PROBE-BIND threw " + x.getClass().getName() + ": " + String.valueOf(x.getMessage()).split("\n")[0]);
                Throwable t = x; while (t.getCause() != null && t.getCause() != t) t = t.getCause();
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("exception", x.getClass().getName(), "root", t.getClass().getName() + ": " + String.valueOf(t.getMessage()).split("\n")[0]));
            }
        }

        // the companion read (D19): every customer row straight from the repository, the same shape on H2 and PostgreSQL
        @GetMapping("/probe/v1/rows")
        List<Map<String, Object>> rows() {
            List<Map<String, Object>> out = new ArrayList<>();
            for (CustomerEntity c : customers.findAll()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", c.getId()); m.put("name", c.getName()); m.put("meals", c.getMealsPerDay()); m.put("price", c.getPricePerMeal());
                m.put("mealType", String.valueOf(c.getMealType())); m.put("version", c.getVersion()); m.put("createdAt", String.valueOf(c.getCreatedAt()));
                out.add(m);
            }
            out.sort((a, b) -> Long.compare((Long) a.get("id"), (Long) b.get("id")));
            return out;
        }
    }
}
