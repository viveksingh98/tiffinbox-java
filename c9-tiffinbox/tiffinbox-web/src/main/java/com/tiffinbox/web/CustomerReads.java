package com.tiffinbox.web;

import com.tiffinbox.Customer;
import com.tiffinbox.CustomerRepository;
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

    @GetMapping("/api/v1/customers/{name}")
    Customer one(@PathVariable String name) throws SQLException {
        return repo.findByName(name).orElseThrow(() -> new CustomerNotFound(name));
    }
}
