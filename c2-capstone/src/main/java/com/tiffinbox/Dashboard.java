package com.tiffinbox;

import java.util.List;
import java.util.concurrent.StructuredTaskScope;
import java.util.concurrent.StructuredTaskScope.Joiner;
import java.util.concurrent.StructuredTaskScope.Subtask;

/**
 * Structured concurrency: three reads, forked together, joined in the block that
 * started them. PREVIEW in JDK 25 (JEP 505) — the project compiles and runs with
 * --enable-preview.
 *
 * awaitAllSuccessfulOrThrow is the joiner that wants no result of its own, so each
 * Subtask keeps the type fork() gave it: no cast, no @SuppressWarnings anywhere.
 */
public final class Dashboard {

    public record View(List<Customer> customers, int monthRevenue, int pausedDays) {}

    private final CustomerRepository repo;

    public Dashboard(CustomerRepository repo) {
        this.repo = repo;
    }

    public View load() throws Exception {
        try (var scope = StructuredTaskScope.open(Joiner.<Object>awaitAllSuccessfulOrThrow())) {
            Subtask<List<Customer>> customers = scope.fork(repo::findAll);
            Subtask<Integer> revenue = scope.fork(repo::monthRevenue);
            Subtask<Integer> paused = scope.fork(repo::pausedDays);
            scope.join();                       // all three, or an exception — never a leak
            return new View(customers.get(), revenue.get(), paused.get());
        }
    }
}
