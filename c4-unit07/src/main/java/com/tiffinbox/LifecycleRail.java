package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * The whole rail in one capture: everything the container does to one bean, in the order it
 * did it. The step numbers and the totals are DERIVED by Trace, which counts what it printed.
 */
public final class LifecycleRail {

    private LifecycleRail() { }

    public static void main(String[] args) throws Exception {
        Trace.printing(true);
        System.out.println("BUILDING — refresh() begins");
        int afterStart;
        int afterRefresh;
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(KitchenConfig.class)) {
            afterRefresh = Trace.count();
            System.out.println();
            System.out.println("RUNNING  — refresh() has returned; the kitchen is open");
            System.out.println("  kitchen.customers() = " + ctx.getBean(Kitchen.class).customers());
            System.out.println();
            System.out.println("CLOSING  — close() begins");
        }
        afterStart = Trace.count();
        System.out.println();
        System.out.printf("callbacks while STARTING  %d%n", afterRefresh);
        System.out.printf("callbacks while CLOSING   %d%n", afterStart - afterRefresh);
        System.out.printf("callbacks in total        %d   (counted by the instrument, not typed)%n",
                afterStart);
        if (afterStart == 0) {
            System.err.println("LifecycleRail: the instrument recorded nothing, so the order below "
                    + "is not a measurement.");
            System.exit(2);
        }
    }
}
