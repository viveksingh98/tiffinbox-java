package com.tiffinbox.kitchen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * The MDC across a thread boundary - three states, one run, and nothing raced.
 *
 * <p>The pool is a SINGLE thread and every task is waited for before the next one is
 * submitted, so the order below is the same on every run. That is deliberate: the bug
 * being shown is not a race. It happens every single time, which is exactly why it reaches
 * production.
 */
public final class KitchenHandoff {

    private static final Logger log = LoggerFactory.getLogger("kitchen");

    private record Ticket(String orderId, String customer) {}

    private static final List<Ticket> TICKETS = List.of(
            new Ticket("A-4417", "Arun"),
            new Ticket("B-9082", "Bela"));

    public static void main(String[] args) throws Exception {
        try (ExecutorService kitchen = Executors.newSingleThreadExecutor()) {

            log.info("--- state 1: hand the work over and hope ---");
            for (Ticket t : TICKETS) {
                MDC.put("orderId", t.orderId());
                log.info("accepted {}", t.customer());
                run(kitchen, () -> { log.info("cooking {}", t.customer()); return null; });
                MDC.remove("orderId");
            }

            log.info("--- state 2: copy the map in, forget to take it out ---");
            for (Ticket t : TICKETS) {
                // Only the FIRST caller remembers to capture. That is the realistic bug:
                // one code path was fixed and the other was not.
                Map<String, String> captured = t.orderId().startsWith("A")
                        ? Map.of("orderId", t.orderId())
                        : null;
                MDC.put("orderId", t.orderId());
                log.info("accepted {}", t.customer());
                run(kitchen, () -> {
                    if (captured != null) {
                        MDC.setContextMap(captured);      // ... and never cleared
                    }
                    log.info("cooking {}", t.customer());
                    return null;
                });
                MDC.remove("orderId");
            }
        }
    }

    /** Submit, wait, and let any failure out - so nothing here can pass silently. */
    private static void run(ExecutorService pool, Callable<Void> work) throws Exception {
        pool.submit(work).get();
    }
}
