package com.tiffinbox;

import java.util.List;
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.Joiner;

/**
 * Unit 17: three reads, forked together, joined in the block that started them.
 * PREVIEW in JDK 25 (JEP 505) — the whole project compiles and runs with --enable-preview.
 */
public final class Dashboard {

    public record View(List<Customer> customers, int monthRevenue, int pausedDays) {}

    private final CustomerRepository repo;

    public Dashboard(CustomerRepository repo) {
        this.repo = repo;
    }

    @SuppressWarnings("preview")
    public View load() throws Exception {
        try (var scope = StructuredTaskScope.open(Joiner.<Object>awaitAllSuccessfulOrThrow())) {
            var customers = scope.fork(repo::findAll);
            var revenue = scope.fork(repo::monthRevenue);
            var paused = scope.fork(repo::pausedDays);
            scope.join();                       // all three, or an exception — never a leak
            @SuppressWarnings("unchecked")
            var list = (List<Customer>) customers.get();
            return new View(list, (Integer) revenue.get(), (Integer) paused.get());
        }
    }
}
