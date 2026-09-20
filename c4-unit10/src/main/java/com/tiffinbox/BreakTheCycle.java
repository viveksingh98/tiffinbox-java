package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * The failure receipt, uncaught, so the exit code is the container's and the whole chain is on
 * screen. The useful line is not in the first eight — it is at the bottom of a three-link
 * {@code Caused by:} chain, and it is the only line that names the shape of the problem.
 */
public final class BreakTheCycle {

    private BreakTheCycle() { }

    public static void main(String[] args) {
        new AnnotationConfigApplicationContext(Cycle.BothConstructors.class);
    }
}
