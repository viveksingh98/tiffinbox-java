package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * Course 6, the capstone: a bulk upload - many customers in one request, from a CSV file.
 *
 * <p>POST /customers/import takes a multipart form (multipart/form-data) whose part "file" is the file: Spring MVC hands it to
 * this method as a MultipartFile; a request with no such part is Spring MVC's 400 ("Required part 'file' is not present.").
 * The file's lines are {@code name,mealsPerDay,pricePerMeal,mealType}, a first line that starts {@code name,} is the header and
 * is skipped. Each row becomes a Customer and goes through what one POST /customers goes through: the same rules, checked by
 * the same validator - Boot's, the one Spring MVC checks a {@code @Valid} body with, its messages in the request's language -
 * then the same repository, where a name that is taken is H2's SQLSTATE 23505. A row that is stored is told to CustomerFeed,
 * as every new customer is. A row that is refused is named by its line, with why: the wrong number of values, a value that is
 * not a number, the rules it broke (each field with every message it earned, sorted, as the 400 lists them), or a name that
 * is taken. The answer is 200 and says what happened to the file: {@code {"file": its name, "added": how many rows were
 * stored, "refused": {"line N": why}}}. A row that fails does not stop the rows after it; any other database refusal is
 * Spring MVC's 500, after the rows before it were stored.
 */
@RestController
final class CustomerImport {

    /** H2's SQLSTATE for a row whose name is already in the table (TiffinBoxServer's NAME_TAKEN). */
    private static final String NAME_TAKEN = "23505";

    private final CustomerRepository repo;
    private final Validator validator;
    private final CustomerFeed feed;

    CustomerImport(CustomerRepository repo, Validator validator, CustomerFeed feed) {
        this.repo = repo;
        this.validator = validator;
        this.feed = feed;
    }

    @PostMapping(path = "/customers/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    Map<String, Object> importCsv(@RequestPart("file") MultipartFile file) throws IOException, SQLException {
        List<String> lines = new String(file.getBytes(), StandardCharsets.UTF_8).lines().toList();
        int added = 0;
        var refused = new LinkedHashMap<String, String>();
        for (int i = 0; i < lines.size(); i++) {
            String line = lines.get(i);
            if (i == 0 && line.startsWith("name,")) {
                continue;
            }
            String where = "line " + (i + 1);
            String[] values = line.split(",", -1);
            if (values.length != 4) {
                refused.put(where, "4 values expected, " + values.length + " found");
                continue;
            }
            Customer customer;
            try {
                customer = new Customer(values[0], Integer.parseInt(values[1].trim()), Integer.parseInt(values[2].trim()),
                        values[3].trim());
            } catch (NumberFormatException e) {
                refused.put(where, "not a number: " + e.getMessage());
                continue;
            }
            String broken = brokenRules(customer);
            if (broken != null) {
                refused.put(where, broken);
                continue;
            }
            try {
                repo.add(customer);
            } catch (SQLException e) {
                if (NAME_TAKEN.equals(e.getSQLState())) {
                    refused.put(where, "a customer named " + customer.name() + " already exists");
                    continue;
                }
                throw e;
            }
            feed.added(customer);
            added++;
        }
        var answer = new LinkedHashMap<String, Object>();
        answer.put("file", file.getOriginalFilename());
        answer.put("added", added);
        answer.put("refused", refused);
        return answer;
    }

    /** The rules a row broke - "field: message; message, field: message", fields and messages sorted - or null for none. */
    private String brokenRules(Customer customer) {
        var fields = new TreeMap<String, TreeSet<String>>();
        for (ConstraintViolation<Customer> v : validator.validate(customer)) {
            fields.computeIfAbsent(v.getPropertyPath().toString(), f -> new TreeSet<>()).add(v.getMessage());
        }
        if (fields.isEmpty()) {
            return null;
        }
        var parts = new ArrayList<String>();
        fields.forEach((field, messages) -> parts.add(field + ": " + String.join("; ", messages)));
        return String.join(", ", parts);
    }
}
