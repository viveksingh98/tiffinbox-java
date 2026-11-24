package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import jakarta.json.Json;
import jakarta.json.JsonArray;
import jakarta.json.JsonException;
import jakarta.json.JsonObject;
import jakarta.json.JsonReader;
import jakarta.json.JsonString;
import jakarta.json.JsonValue;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.json.JsonMapper;

import java.io.ByteArrayInputStream;
import java.sql.SQLException;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.function.Function;

/**
 * Course 9, unit 05: the public API's partial update - PATCH /api/v1/customers/{name}, in RFC 7396's merge patch
 * (application/merge-patch+json) or RFC 6902's JSON Patch (application/json-patch+json). JSON-P applies the patch -
 * Json.createMergePatch and Json.createPatch, Parsson's implementation - to the customer as JSON; the result is read back into the
 * Customer record by Boot's JsonMapper (Jackson 3) and checked against the record's rules by Boot's Validator, so every patched
 * document is a whole customer before anything is written. CustomerRepository.update writes it and empties the caches it changes.
 *
 * <p>The answers (RFC 5789 section 2.2): 200 and the stored customer; 400 for a patch document that is not one (not JSON, a JSON
 * Patch that is not an array of operations, an unknown op, a missing value, a path to no member - checked before JSON-P applies
 * it); 404 for a name nobody has (CustomerNotFound, TiffinBoxErrors); 409 for a failed test operation and for a rename to a taken
 * name; 422 for a patched document that is not a valid customer; any other media type is Spring MVC's 415, which names both in
 * Accept-Patch. Every refusal of the route's own is a ProblemDetail in its own words: no class name, no parser text. PATCH is not
 * keyed (IdempotencyKeyFilter guards two POSTs only).
 */
@RestController
final class CustomerPatches {

    private static final System.Logger LOG = System.getLogger("tiffinbox.patch");

    static final String MERGE_PATCH = "application/merge-patch+json";
    static final String JSON_PATCH = "application/json-patch+json";

    /** The customer's members: a JSON Patch path names one of them, or it names no member. */
    private static final Set<String> MEMBERS = Set.of("name", "mealsPerDay", "pricePerMeal", "mealType");

    /** H2's and PostgreSQL's SQLSTATE for a row whose name is already in the table. */
    private static final String NAME_TAKEN = "23505";

    private final CustomerRepository repo;
    private final JsonMapper json;
    private final Validator validator;

    CustomerPatches(CustomerRepository repo, JsonMapper json, Validator validator) {
        this.repo = repo;
        this.json = json;
        this.validator = validator;
    }

    @PatchMapping(path = "/api/v1/customers/{name}", consumes = MERGE_PATCH)
    ResponseEntity<?> merge(@PathVariable String name, @RequestBody byte[] body) throws SQLException {
        JsonValue patch = parse(body);
        if (patch == null) {
            return refuse(HttpStatus.BAD_REQUEST, "Malformed patch", "the merge patch is not JSON");
        }
        return apply(name, Json.createMergePatch(patch)::apply, false);
    }

    @PatchMapping(path = "/api/v1/customers/{name}", consumes = JSON_PATCH)
    ResponseEntity<?> jsonPatch(@PathVariable String name, @RequestBody byte[] body) throws SQLException {
        JsonValue patch = parse(body);
        if (patch == null) {
            return refuse(HttpStatus.BAD_REQUEST, "Malformed patch", "the JSON Patch is not JSON");
        }
        String shape = shapeError(patch);
        if (shape != null) {
            return refuse(HttpStatus.BAD_REQUEST, "Malformed patch", shape);
        }
        JsonArray ops = patch.asJsonArray();
        boolean tests = ops.stream().anyMatch(op -> "test".equals(op.asJsonObject().getString("op")));
        return apply(name, Json.createPatch(ops)::apply, tests);
    }

    /** JSON-P's reading of the body, or null when it is not JSON. */
    private static JsonValue parse(byte[] body) {
        try (JsonReader r = Json.createReader(new ByteArrayInputStream(body))) {
            return r.readValue();
        } catch (JsonException e) {
            return null;
        }
    }

    /** RFC 6902 section 4's shape, checked before JSON-P applies anything: null when the patch is an array of whole operations. */
    private static String shapeError(JsonValue patch) {
        if (patch.getValueType() != JsonValue.ValueType.ARRAY) {
            return "a JSON Patch is an array of operations";
        }
        int i = 0;
        for (JsonValue v : patch.asJsonArray()) {
            if (v.getValueType() != JsonValue.ValueType.OBJECT) {
                return "operation " + i + " is not an object";
            }
            JsonObject op = v.asJsonObject();
            String name = text(op, "op");
            if (name == null || !Set.of("add", "remove", "replace", "move", "copy", "test").contains(name)) {
                return "operation " + i + " has no op this route knows";
            }
            if (!member(text(op, "path"))) {
                return "operation " + i + " has a path to no member";
            }
            if (Set.of("add", "replace", "test").contains(name) && !op.containsKey("value")) {
                return "operation " + i + " (" + name + ") has no value";
            }
            if (Set.of("move", "copy").contains(name) && !member(text(op, "from"))) {
                return "operation " + i + " (" + name + ") has a from to no member";
            }
            i++;
        }
        return null;
    }

    private static String text(JsonObject op, String key) {
        JsonValue v = op.get(key);
        return v instanceof JsonString s ? s.getString() : null;
    }

    private static boolean member(String pointer) {
        return pointer != null && pointer.startsWith("/") && MEMBERS.contains(pointer.substring(1));
    }

    /** The patch applied to the stored customer inside CustomerRepository.update's transaction; the answer the route gives. */
    private ResponseEntity<?> apply(String name, Function<JsonObject, JsonValue> patch, boolean tests) throws SQLException {
        try {
            Customer stored = repo.update(name, current -> readBack(patched(patch, current, tests)))
                    .orElseThrow(() -> new CustomerNotFound(name));
            return ResponseEntity.ok(stored);
        } catch (Refused r) {
            return refuse(r.status, r.title, r.getMessage(), r.errors);
        } catch (SQLException e) {
            if (NAME_TAKEN.equals(e.getSQLState())) {
                return refuse(HttpStatus.CONFLICT, "Name taken", "a customer with that name already exists");
            }
            throw e;
        }
    }

    private JsonValue patched(Function<JsonObject, JsonValue> patch, Customer current, boolean tests) {
        JsonObject doc;
        try (JsonReader r = Json.createReader(new ByteArrayInputStream(json.writeValueAsBytes(current)))) {
            doc = r.readObject();
        }
        try {
            return patch.apply(doc);
        } catch (JsonException e) {
            LOG.log(System.Logger.Level.INFO, "PATCH refused - JSON-P''s words: {0}", e.getMessage());
            throw tests
                    ? new Refused(HttpStatus.CONFLICT, "Test failed", "a test operation in the patch does not hold", null)
                    : new Refused(HttpStatus.BAD_REQUEST, "Malformed patch", "the patch could not be applied", null);
        }
    }

    /** The patched document read back into the record, then checked against its rules: a whole, valid customer, or a 422. */
    private Customer readBack(JsonValue doc) {
        if (doc.getValueType() != JsonValue.ValueType.OBJECT) {
            throw new Refused(HttpStatus.UNPROCESSABLE_CONTENT, "Invalid customer", "the patched document is not a customer", null);
        }
        Customer c;
        try {
            c = json.readValue(doc.toString(), Customer.class);
        } catch (JacksonException e) {
            String member = e.getPath().isEmpty() ? null : e.getPath().getLast().getPropertyName();
            throw new Refused(HttpStatus.UNPROCESSABLE_CONTENT, "Invalid customer",
                    member == null ? "the patched customer cannot be read" : "the patched customer cannot be read at " + member, null);
        }
        Set<ConstraintViolation<Customer>> broken = validator.validate(c);
        if (!broken.isEmpty()) {
            var all = new TreeMap<String, TreeSet<String>>();
            for (ConstraintViolation<Customer> v : broken) {
                all.computeIfAbsent(v.getPropertyPath().toString(), f -> new TreeSet<>()).add(v.getMessage());
            }
            var errors = new TreeMap<String, String>();
            all.forEach((field, messages) -> errors.put(field, String.join("; ", messages)));
            throw new Refused(HttpStatus.UNPROCESSABLE_CONTENT, "Invalid customer",
                    "the patched customer breaks " + errors.size() + (errors.size() == 1 ? " rule" : " rules"), errors);
        }
        return c;
    }

    private static ResponseEntity<ProblemDetail> refuse(HttpStatus status, String title, String detail) {
        return refuse(status, title, detail, null);
    }

    private static ResponseEntity<ProblemDetail> refuse(HttpStatus status, String title, String detail, TreeMap<String, String> errors) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setTitle(title);
        if (errors != null) {
            problem.setProperty("errors", errors);
        }
        return ResponseEntity.status(status).body(problem);
    }

    /** A refusal of the route's own, thrown inside update's transaction: nothing is written, and the route answers it. */
    private static final class Refused extends RuntimeException {
        final HttpStatus status;
        final String title;
        final TreeMap<String, String> errors;

        Refused(HttpStatus status, String title, String detail, TreeMap<String, String> errors) {
            super(detail, null, false, false);
            this.status = status;
            this.title = title;
            this.errors = errors;
        }
    }
}
