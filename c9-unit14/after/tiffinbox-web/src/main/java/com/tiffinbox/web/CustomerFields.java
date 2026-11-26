package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;

/**
 * Course 9, unit 14: the customer list, GET /api/v1/customers - every customer CustomerRepository lists, as a JSON array; with
 * ?fields=name,mealType each customer is narrowed to the fields named (a sparse fieldset). The fields a client may name are a
 * whitelist, the Customer record's four components in the record's order (name, mealsPerDay, pricePerMeal, mealType), and a narrowed
 * object holds its members in that order, whatever order the request names them in. No member is ever taken from the request: the
 * request only picks from the whitelist.
 *
 * <p>It refuses what it does not know, each a four hundred with its own problem type (tag:tiffinbox.example,2026:...): a field the
 * record does not have, case included (field-unknown, the detail naming the accepted fields); a parameter other than fields
 * (parameter-unknown); a fields value that is empty, holds an empty name (a trailing comma) or names a field twice, or a fields
 * parameter sent more than once (fields-invalid).
 *
 * <p>What it does NOT do: it is not an access control - a fieldset hides nothing from a caller who asks for the whole list (who may
 * read which customer is Course 10's, The Threat Model First); no paging (the order list's cursor is unit 13's); no compression of its
 * own - Boot's switch is a run flag (--server.compression.enabled=true), never a default in application.yaml, which would add a Vary
 * header to old answers; no Jackson view and no wrapper value (the receipts measure both on the harness's routes only).
 *
 * <p>final, as OrderPages is: no proxy is made of it.
 */
@RestController
final class CustomerFields {

    private static final String TYPE = "tag:tiffinbox.example,2026:";

    /** The fields a client may name: the Customer record's components, in the record's order - the only ones. */
    static final Map<String, Function<Customer, Object>> FIELDS = new LinkedHashMap<>();
    static {
        FIELDS.put("name", Customer::name);
        FIELDS.put("mealsPerDay", Customer::mealsPerDay);
        FIELDS.put("pricePerMeal", Customer::pricePerMeal);
        FIELDS.put("mealType", Customer::mealType);
    }

    /** The query parameters this route reads; any other is refused. */
    static final Set<String> PARAMETERS = Set.of("fields");

    private final CustomerRepository customers;

    CustomerFields(CustomerRepository customers) {
        this.customers = customers;
    }

    @ApiResponse(responseCode = "200", description = "OK - every customer; with fields, each object holds only the fields named, in the"
            + " record's order", content = @Content(mediaType = "application/json",
            array = @ArraySchema(schema = @Schema(implementation = Customer.class))))
    @ApiResponse(responseCode = "400", description = "An unknown field or parameter, or a fields value that is empty, holds an empty name,"
            + " names a field twice or is sent more than once", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class)))
    @GetMapping("/api/v1/customers")
    List<?> customerFields(@Parameter(description = "a comma-separated list of name, mealsPerDay, pricePerMeal, mealType")
                           @RequestParam(required = false) String fields, HttpServletRequest request) throws SQLException {
        List<String> unknown = new ArrayList<>();
        for (String p : Collections.list(request.getParameterNames())) if (!PARAMETERS.contains(p)) unknown.add(p);
        if (!unknown.isEmpty()) {
            throw refusal("parameter-unknown", "Unknown parameter", "unknown parameter " + unknown + "; this route reads " + PARAMETERS);
        }
        List<Customer> all = customers.findAll();
        if (fields == null) return all;
        String[] sent = request.getParameterValues("fields");
        if (sent != null && sent.length > 1) throw refusal("fields-invalid", "Invalid fields", "fields is sent once, as a comma-separated list");
        Set<String> asked = new LinkedHashSet<>();
        for (String f : fields.split(",", -1)) {
            if (f.isEmpty()) throw refusal("fields-invalid", "Invalid fields", "fields holds an empty name; it is a comma-separated list of " + FIELDS.keySet());
            if (!FIELDS.containsKey(f)) throw refusal("field-unknown", "Unknown field", "unknown field " + f + "; the fields are " + FIELDS.keySet());
            if (!asked.add(f)) throw refusal("fields-invalid", "Invalid fields", "fields names " + f + " twice");
        }
        return all.stream().map(c -> {
            Map<String, Object> m = new LinkedHashMap<>();
            FIELDS.forEach((name, read) -> { if (asked.contains(name)) m.put(name, read.apply(c)); });
            return m;
        }).toList();
    }

    private static ErrorResponseException refusal(String type, String title, String detail) {
        ProblemDetail p = ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, detail);
        p.setType(URI.create(TYPE + type));
        p.setTitle(title);
        return new ErrorResponseException(HttpStatus.BAD_REQUEST, p, null);
    }
}
