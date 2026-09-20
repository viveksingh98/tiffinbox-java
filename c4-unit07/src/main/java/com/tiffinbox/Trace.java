package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;

/**
 * The instrument. Every callback the container hands the kitchen appends one line here, and
 * the STEP NUMBER is the size of the list at the time — so the count of callbacks is derived
 * by the run, never typed into the program and never typed onto a slide.
 *
 * <p>Recording is always on; PRINTING is not, so ContextReport can open a context and count
 * the callbacks without the rail's own output landing in the middle of the receipt.
 */
public final class Trace {

    private static final List<String> STEPS = new ArrayList<>();
    private static boolean printing;

    private Trace() { }

    public static void printing(boolean on) {
        printing = on;
    }

    public static void step(String what) {
        STEPS.add(what);
        if (printing) {
            System.out.printf("  %2d  %s%n", STEPS.size(), what);
        }
    }

    public static int count() {
        return STEPS.size();
    }

    public static List<String> steps() {
        return List.copyOf(STEPS);
    }
}
