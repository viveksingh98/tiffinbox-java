package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;

/**
 * Course 9, unit 06: the review's one fix - the public API could change a customer (PATCH /api/v1/customers/{name}, CustomerPatches)
 * but not read one back: a GET there answered 405. This route reads the customer the old GET /customers/{name} reads, through the
 * same CustomerRepository.findByName and its "customer" cache, so the rename's eviction (CustomerRepository.update) reaches both
 * addresses. A name nobody has is CustomerNotFound (TiffinBoxErrors: a 404). The old route is unchanged.
 *
 * <p>Course 9, unit 20: this route sends a validator - {@code ETag: "v<version>"}, the version of the customer's row (CustomerEntity's
 * {@code @Version}), read with the customer in one SELECT by CustomerRepository.findVersioned, never from the "customer" cache: every
 * answer of this route, a 200 or a 304, costs that one statement (the cached read it replaces cost none when warm). A request whose
 * If-None-Match names the current tag answers 304 with no body - Spring's HttpEntityMethodProcessor compares it through
 * ServletWebRequest.checkNotModified: the handler runs and the row is read; only the body is not written. The parameter list stays
 * (String): OrderResources looks this method up by it for the order's customer link. ConditionalGets' shallow filter keeps this tag: it hashes a body only when the
 * handler set no tag. The old address GET /customers/{name} sends no validator and still reads the cache.
 */
@RestController
final class CustomerReads {

    private final CustomerRepository repo;

    CustomerReads(CustomerRepository repo) {
        this.repo = repo;
    }

    // Course 9, unit 09: the documented not-found problem - Framework's ProblemDetail schema, an example equal to the answer this route sent
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "customer-not-found", value = "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}")))
    @GetMapping("/api/v1/customers/{name}")
    ResponseEntity<Customer> one(@PathVariable String name) throws SQLException {
        CustomerRepository.Versioned found = repo.findVersioned(name).orElseThrow(() -> new CustomerNotFound(name));
        // Course 9, unit 20: the deep tag; Spring's entity processor compares If-None-Match with it (checkNotModified) and answers 304
        return ResponseEntity.ok().eTag(tag(found.version())).body(found.customer());
    }

    /** Course 9, unit 20: the tag of a row's version, quoted - a strong tag (no W/). CustomerPatches compares If-Match against it. */
    static String tag(long version) {
        return "\"v" + version + "\"";
    }
}
