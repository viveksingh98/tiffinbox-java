package com.tiffinbox;

import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

/**
 * Three database reads, started together and joined in the block that started them.
 *
 * <p>Core Java II wrote this with {@code StructuredTaskScope}, which is a PREVIEW API in
 * JDK 25 (JEP 505) and so needs {@code --enable-preview} at compile time <em>and</em> again
 * at run time. Nothing is wrong with that code — but a preview flag pins the project to one
 * exact JDK, and this build has to run on more than one (a JDK matrix in CI, a Gradle build
 * beside these POMs, and a native image later). So the fan-out keeps its shape on a plain
 * virtual-thread executor: {@code invokeAll} submits all three and returns only when all
 * three are finished, and {@code close()} cannot leave a task running.
 *
 * <p>The one thing the preview API did better: {@code fork} kept each task's own return
 * type. {@code invokeAll} takes <em>one</em> list, so every task here is a
 * {@code Callable<Object>} and the customer list is checked on the way out — that is the
 * {@link #customers} helper below, and it is the whole cost of the trade.
 */
public final class Dashboard {

    public record View(List<Customer> customers, int monthRevenue, int pausedDays) {}

    private final CustomerRepository repo;

    public Dashboard(CustomerRepository repo) {
        this.repo = repo;
    }

    public View load() throws Exception {
        List<Callable<Object>> reads = List.of(repo::findAll, repo::monthRevenue, repo::pausedDays);
        try (ExecutorService scope = Executors.newVirtualThreadPerTaskExecutor()) {
            List<Future<Object>> done = scope.invokeAll(reads);   // all three, or none
            return new View(customers(done.get(0)),
                            (Integer) done.get(1).get(),
                            (Integer) done.get(2).get());
        }
    }

    /** One list in, so the element type is erased: check it back, one element at a time. */
    private static List<Customer> customers(Future<Object> read) throws Exception {
        return ((List<?>) read.get()).stream().map(Customer.class::cast).toList();
    }
}
