package com.tiffinbox.kitchen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.tiffinbox.kitchen.Mdc.carrying;

/**
 * The same hand-off as breaks/mdc-lost, done so the id travels and does not linger.
 *
 * <p>The three lines of discipline that make it work are in {@link Mdc#carrying}, with the
 * reason for each one written above them. This class is what using it looks like.
 */
public final class KitchenPool {

    private static final Logger log = LoggerFactory.getLogger("kitchen");

    private record Ticket(String orderId, String customer) {}

    private static final List<Ticket> TICKETS = List.of(
            new Ticket("A-4417", "Arun"),
            new Ticket("B-9082", "Bela"));

    public static void main(String[] args) throws Exception {
        try (ExecutorService kitchen = Executors.newSingleThreadExecutor()) {
            for (Ticket t : TICKETS) {
                MDC.put("orderId", t.orderId());
                try {
                    log.info("accepted {}", t.customer());
                    kitchen.submit(carrying(() -> {
                        log.info("cooking {}", t.customer());
                        return null;
                    })).get();
                } finally {
                    MDC.remove("orderId");
                }
            }
            // and one task submitted with NOTHING in the MDC, to prove the clear() branch:
            // a pooled thread that has just carried A-4417 must not offer it to this one.
            kitchen.submit(carrying(() -> {
                log.info("end of service");
                return null;
            })).get();
        }
    }

}
