package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;

/**
 * Course 9, unit 06: the review's one fix - the public API could change a customer (PATCH /api/v1/customers/{name}, CustomerPatches)
 * but not read one back: a GET there answered 405. This route reads the customer the old GET /customers/{name} reads, through the
 * same CustomerRepository.findByName and its "customer" cache, so the rename's eviction (CustomerRepository.update) reaches both
 * addresses. A name nobody has is CustomerNotFound (TiffinBoxErrors: a 404). No validator header is sent here: ETags and
 * Conditional GET is that lesson's. The old route is unchanged.
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
    Customer one(@PathVariable String name) throws SQLException {
        return repo.findByName(name).orElseThrow(() -> new CustomerNotFound(name));
    }
}
