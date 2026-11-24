package probe;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import com.tiffinbox.MealType;
import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonException;
import jakarta.json.JsonObject;
import jakarta.json.JsonStructure;
import jakarta.json.JsonValue;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import org.springframework.cache.CacheManager;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.io.StringReader;
import java.lang.reflect.Field;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

/**
 * LANE 6's probe harness (Course 9 S1), never TiffinBox's: LABELLED PATCH routes under /probe/** - the four ways U05 compares.
 * naive (bind the whole record, save it, no validation, NO eviction: read the row by a second client), naivevalid (the same with
 * @Valid), merge (application/merge-patch+json into Jackson 3's JsonNode: absent and null told apart; evicts), mergep (the same
 * through JSON-P's createMergePatch, RFC 7396's own algorithm), jsonpatch (application/json-patch+json read by Spring MVC's
 * converter, applied by JSON-P's createPatch with Parsson; evicts), rename (the name is the identity: evicts `customers` and both
 * names in `customer`) and rename-noevict (the PLANTED no-evict copy: the save through CustomerEntityRepository alone).
 */
@RestController
public class Patch {
    private final CustomerEntityRepository rows;
    private final CacheManager caches;
    private final Validator validator;
    private final ObjectMapper mapper;

    Patch(CustomerEntityRepository rows, CacheManager caches, Validator validator, ObjectMapper mapper) {
        this.rows = rows;
        this.caches = caches;
        this.validator = validator;
        this.mapper = mapper;
    }

    static void set(Object o, String field, Object v) {
        try {
            Field f = CustomerEntity.class.getDeclaredField(field);
            f.setAccessible(true);
            f.set(o, v);
        } catch (ReflectiveOperationException e) {
            throw new IllegalStateException(e);
        }
    }

    static Customer record(CustomerEntity e) {
        return new Customer(e.getName(), e.getMealsPerDay(), e.getPricePerMeal(), e.getMealType() == null ? null : e.getMealType().name());
    }

    private CustomerEntity load(String name) {
        return rows.findByName(name).orElseThrow(() -> new IllegalArgumentException("probe: no customer named " + name));
    }

    private void apply(CustomerEntity e, Customer c) {
        set(e, "mealsPerDay", c.mealsPerDay());
        set(e, "pricePerMeal", c.pricePerMeal());
        set(e, "mealType", c.mealType() == null ? null : MealType.valueOf(c.mealType()));
    }

    private void evict(String... names) {
        caches.getCache("customers").clear();
        for (String n : names) caches.getCache("customer").evict(n);
    }

    private ResponseEntity<Object> invalid(Customer merged) {
        var fields = new TreeMap<String, String>();
        for (ConstraintViolation<Customer> v : validator.validate(merged)) fields.merge(v.getPropertyPath().toString(), v.getMessage(), (a, b) -> a + "; " + b);
        if (fields.isEmpty()) return null;
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, "the patched customer breaks " + fields.size() + " rule(s)");
        p.setProperty("errors", fields);
        return ResponseEntity.badRequest().body(p);
    }

    @PatchMapping(path = "/probe/naive/customers/{name}", consumes = "application/json")
    Customer naive(@PathVariable String name, @RequestBody Customer body) {
        CustomerEntity e = load(name);
        apply(e, body);                       // every field of the bound record, absent ones included
        return record(rows.save(e));          // no eviction: read the row by a second client
    }

    @PatchMapping(path = "/probe/naivevalid/customers/{name}", consumes = "application/json")
    ResponseEntity<Object> naiveValid(@PathVariable String name, @Valid @RequestBody Customer body, BindingResult errors) {
        if (errors.hasErrors()) {
            var fields = new TreeMap<String, String>();
            errors.getFieldErrors().forEach(f -> fields.merge(f.getField(), f.getDefaultMessage(), (a, b) -> a + "; " + b));
            ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, "the body breaks " + errors.getFieldErrorCount() + " rule(s)");
            p.setProperty("errors", fields);
            return ResponseEntity.badRequest().body(p);
        }
        CustomerEntity e = load(name);
        apply(e, body);
        return ResponseEntity.ok(record(rows.save(e)));
    }

    @PatchMapping(path = "/probe/merge/customers/{name}", consumes = "application/merge-patch+json")
    ResponseEntity<Object> merge(@PathVariable String name, @RequestBody JsonNode patch) {
        CustomerEntity e = load(name);
        Customer now = record(e);
        var said = new LinkedHashMap<String, String>();
        int meals = now.mealsPerDay(), price = now.pricePerMeal();
        String type = now.mealType();
        for (String f : new String[] {"mealsPerDay", "pricePerMeal", "mealType"}) {
            if (!patch.has(f)) {
                said.put(f, "absent: kept");
                continue;
            }
            JsonNode v = patch.get(f);
            if (v.isNull()) {
                ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT, f + " is null: merge patch would remove it, and a customer needs it");
                p.setProperty("field", f);
                return ResponseEntity.unprocessableContent().body(p);
            }
            said.put(f, "set");
            switch (f) {
                case "mealsPerDay" -> meals = v.asInt();
                case "pricePerMeal" -> price = v.asInt();
                default -> type = v.asString();
            }
        }
        Customer merged = new Customer(now.name(), meals, price, type);
        ResponseEntity<Object> bad = invalid(merged);
        if (bad != null) return bad;
        apply(e, merged);
        Customer saved = record(rows.save(e));
        evict(name);
        var out = new LinkedHashMap<String, Object>();
        out.put("customer", saved);
        out.put("fields", said);
        return ResponseEntity.ok(out);
    }

    private JsonObject asJsonP(Customer c) {
        return Json.createReader(new StringReader(mapper.writeValueAsString(c))).readObject();
    }

    @PatchMapping(path = "/probe/mergep/customers/{name}", consumes = "application/merge-patch+json")
    ResponseEntity<Object> mergeP(@PathVariable String name, @RequestBody String patch, @RequestParam(defaultValue = "0") int mapped) {
        CustomerEntity e = load(name);
        JsonValue p = Json.createReader(new StringReader(patch)).readValue();
        JsonValue merged = Json.createMergePatch(p).apply(asJsonP(record(e)));
        Customer c;
        if (mapped == 1) {
            try {
                c = mapper.readValue(merged.toString(), Customer.class);
            } catch (JacksonException x) {
                return unreadable(x, merged.toString());
            }
        } else {
            c = mapper.readValue(merged.toString(), Customer.class);   // unmapped: the re-read's exception is the handler's
        }
        if (!c.name().equals(name)) return ResponseEntity.unprocessableContent().body(ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT, "a rename is the rename route's"));
        ResponseEntity<Object> bad = invalid(c);
        if (bad != null) return bad;
        apply(e, c);
        Customer saved = record(rows.save(e));
        evict(name);
        return ResponseEntity.ok(Map.of("customer", saved, "merged", merged.toString()));
    }

    @PatchMapping(path = "/probe/jsonpatch/customers/{name}", consumes = "application/json-patch+json")
    ResponseEntity<Object> jsonPatch(@PathVariable String name, @RequestBody JsonNode ops, @RequestParam(defaultValue = "0") int mapped) {
        CustomerEntity e = load(name);
        JsonArray array = Json.createReader(new StringReader(ops.toString())).readArray();
        JsonStructure result;
        try {
            result = Json.createPatch(array).apply(asJsonP(record(e)));
        } catch (JsonException x) {
            ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, String.valueOf(x.getMessage()));
            p.setProperty("exception", x.getClass().getName());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(p);
        }
        Customer c;
        if (mapped == 1) {
            try {
                c = mapper.readValue(result.toString(), Customer.class);
            } catch (JacksonException x) {
                return unreadable(x, result.toString());
            }
        } else {
            c = mapper.readValue(result.toString(), Customer.class);   // unmapped: the re-read's exception is the handler's
        }
        if (!c.name().equals(name)) return ResponseEntity.unprocessableContent().body(ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT, "a rename is the rename route's"));
        ResponseEntity<Object> bad = invalid(c);
        if (bad != null) return bad;
        apply(e, c);
        Customer saved = record(rows.save(e));
        evict(name);
        return ResponseEntity.ok(saved);
    }

    /** BLUE C9-S1 (RED #11): a patched document the record cannot take, as one problem detail (422, RFC 5789 section 2.2's case). */
    private ResponseEntity<Object> unreadable(JacksonException x, String document) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT,
                "the patched document is not a valid customer: " + String.valueOf(x.getOriginalMessage()).lines().findFirst().orElse(""));
        p.setProperty("exception", x.getClass().getName());
        p.setProperty("document", document);
        return ResponseEntity.unprocessableContent().body(p);
    }

    /**
     * BLUE C9-S1 (RED #9): Jackson 3's readerForUpdating on the stored record - a merge with no new dependency. Absent members keep the
     * record's values; what a member set to null or to a wrong type does is printed by the route's answer (mapped=1 maps a read
     * failure to unreadable(); mapped=0 leaves it to the handler).
     */
    @PatchMapping(path = "/probe/reader/customers/{name}", consumes = "application/merge-patch+json")
    ResponseEntity<Object> reader(@PathVariable String name, @RequestBody String patch, @RequestParam(defaultValue = "0") int mapped) {
        CustomerEntity e = load(name);
        Customer now = record(e);
        Customer c;
        if (mapped == 1) {
            try {
                c = mapper.readerForUpdating(now).readValue(patch);
            } catch (JacksonException x) {
                return unreadable(x, patch);
            }
        } else {
            c = mapper.readerForUpdating(now).readValue(patch);
        }
        if (!c.name().equals(name)) return ResponseEntity.unprocessableContent().body(ProblemDetail.forStatusAndDetail(HttpStatus.UNPROCESSABLE_CONTENT, "a rename is the rename route's"));
        ResponseEntity<Object> bad = invalid(c);
        if (bad != null) return bad;
        apply(e, c);
        Customer saved = record(rows.save(e));
        evict(name);
        var out = new LinkedHashMap<String, Object>();
        out.put("before", now);
        out.put("customer", saved);
        return ResponseEntity.ok(out);
    }

    record Rename(String name) {
    }

    @PatchMapping(path = "/probe/rename/customers/{name}", consumes = "application/json")
    Customer rename(@PathVariable String name, @RequestBody Rename to) {
        CustomerEntity e = load(name);
        set(e, "name", to.name());
        Customer saved = record(rows.save(e));
        evict(name, to.name());               // S9.13: customers, and the old and the new name in customer
        return saved;
    }

    @PatchMapping(path = "/probe/rename-noevict/customers/{name}", consumes = "application/json")
    Customer renameNoEvict(@PathVariable String name, @RequestBody Rename to) {
        CustomerEntity e = load(name);
        set(e, "name", to.name());
        return record(rows.save(e));          // PLANTED: the save through CustomerEntityRepository alone - no eviction
    }
}
