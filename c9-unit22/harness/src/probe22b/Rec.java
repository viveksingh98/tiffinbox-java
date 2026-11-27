// BLUE C9-U22 HARNESS (labelled, R.397; never shipped): the record cure on the entity route. The same row, the body read into
// the anchor's Customer record by Boot's message converter (@RequestBody @Valid Customer) instead of into the entity; the row is
// found by the URL's name and only the record's members are copied. Joined ONLY by --spring.main.sources=probe22b.Rec.
package probe22b;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerEntity;
import jakarta.persistence.EntityManager;
import jakarta.validation.Valid;
import java.util.*;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

@Configuration
public class Rec {
    @RestController
    static class RecRoute {
        private final EntityManager em;
        RecRoute(EntityManager em) { this.em = em; }

        @PutMapping("/probe/v1/customers/{name}/record")
        @Transactional
        public ResponseEntity<Map<String, Object>> record(@PathVariable("name") String name, @RequestBody @Valid Customer c) {
            List<CustomerEntity> l = em.createQuery("select c from CustomerEntity c where c.name = :n", CustomerEntity.class).setParameter("n", name).getResultList();
            if (l.isEmpty()) return ResponseEntity.notFound().build();
            CustomerEntity e = l.get(0);
            e.setMealsPerDay(c.mealsPerDay());
            em.flush();
            return ResponseEntity.ok(Map.of("id", e.getId(), "mealsPerDay", e.getMealsPerDay(), "version", e.getVersion()));
        }

        @GetMapping("/probe/v1/recrows")
        public List<Map<String, Object>> rows() {
            List<Map<String, Object>> out = new ArrayList<>();
            for (CustomerEntity c : em.createQuery("select c from CustomerEntity c order by c.id", CustomerEntity.class).getResultList()) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", c.getId()); m.put("name", c.getName()); m.put("meals", c.getMealsPerDay()); m.put("price", c.getPricePerMeal());
                m.put("mealType", String.valueOf(c.getMealType())); m.put("version", c.getVersion());
                out.add(m);
            }
            return out;
        }
    }
}
