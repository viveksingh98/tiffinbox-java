package com.tiffinbox.kitchen;

import org.slf4j.MDC;

import java.util.Map;
import java.util.concurrent.Callable;

/**
 * Carry the calling thread's MDC across a thread boundary, and leave the pooled thread clean.
 *
 * <p>Three lines of discipline, and all three matter:
 * <ol>
 *   <li><b>Capture on the calling thread</b> - {@code getCopyOfContextMap()} while you still
 *       have the context. Reading it inside the task is too late; you are already on the
 *       other thread.</li>
 *   <li><b>Install it on the pool thread</b> - {@code setContextMap}, or {@code clear()} when
 *       the caller had nothing, because a pooled thread arrives carrying whatever the last
 *       task left on it.</li>
 *   <li><b>Take it off in a finally</b> - the thread goes back in the pool either way.</li>
 * </ol>
 *
 * <p>Miss the third and you get breaks/mdc-lost state 2: a line about one customer, labelled
 * with a different customer's order id. Nothing throws, nothing is dropped, and every search
 * you run afterwards gives you a confident wrong answer.
 */
public final class Mdc {

    private Mdc() {}

    public static <T> Callable<T> carrying(Callable<T> work) {
        Map<String, String> captured = MDC.getCopyOfContextMap();   // on the CALLING thread
        return () -> {
            if (captured == null) {
                MDC.clear();
            } else {
                MDC.setContextMap(captured);
            }
            try {
                return work.call();
            } finally {
                MDC.clear();
            }
        };
    }

    public static Runnable carrying(Runnable work) {
        Callable<Void> c = carrying(() -> { work.run(); return null; });
        return () -> {
            try {
                c.call();
            } catch (Exception e) {
                throw new IllegalStateException(e);
            }
        };
    }
}
