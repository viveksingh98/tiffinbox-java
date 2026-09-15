package com.tiffinbox.kitchen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

import java.util.List;
import java.util.concurrent.Semaphore;

/**
 * Two orders being cooked at the same time, and the id that lets you read one of them.
 *
 * <p><b>MDC</b> - Mapped Diagnostic Context - is a map of strings that SLF4J keeps per
 * thread. Anything you put in it is available to the pattern layout as {@code %X{key}},
 * on every line that thread writes, until that thread removes it. Nothing below passes an
 * order id to a logging call: each thread puts it in the MDC once and the layout does the
 * rest.
 *
 * <p>The two threads are deliberately NOT racing. Two semaphores hand control back and
 * forth so the six lines interleave in exactly one order, every run. A concurrency
 * demonstration whose output changes between runs cannot be put on a slide as fixed, and
 * this course does not pretend otherwise - the shape being taught here is which id lands
 * on which line, not who wins a race.
 */
public final class KitchenMdc {

    private static final Logger log = LoggerFactory.getLogger("kitchen");

    private record Ticket(String orderId, String customer, int value) {}

    private static final List<Ticket> TICKETS = List.of(
            new Ticket("A-4417", "Arun", 240),
            new Ticket("B-9082", "Bela", 200));

    public static void main(String[] args) throws Exception {
        var turn = new Semaphore[] { new Semaphore(1), new Semaphore(0) };

        var cooks = new Thread[TICKETS.size()];
        for (int i = 0; i < TICKETS.size(); i++) {
            final int me = i, next = (i + 1) % TICKETS.size();
            final Ticket t = TICKETS.get(i);
            cooks[i] = new Thread(() -> {
                MDC.put("orderId", t.orderId());
                try {
                    for (String step : List.of("accepted", "cooking", "packed")) {
                        turn[me].acquireUninterruptibly();
                        log.info("{} for {} ({} rupees)", step, t.customer(), t.value());
                        turn[next].release();
                    }
                } finally {
                    MDC.remove("orderId");        // a thread is reused; the id must not be
                }
            }, "cook-" + (i + 1));
        }
        for (Thread c : cooks) c.start();
        for (Thread c : cooks) c.join();

        log.info("both tickets done");            // no orderId in the MDC on this thread
    }
}
