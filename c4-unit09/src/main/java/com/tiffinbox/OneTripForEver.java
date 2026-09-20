package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * A / B / A′ in one program, one JVM, one session: a prototype injected into a singleton, the
 * injection point changed by one type, and back again. Three captures, one hash.
 */
public final class OneTripForEver {

    /**
     * The identityHashCode pair is the one token here that is not portable. It reproduces on
     * this machine — HotSpot's default generator is a fixed-seed thread-local sequence, so a
     * deterministic single-threaded program gets the same values across JVM restarts — and it
     * moves the moment anyone changes a JVM flag or a machine. So --stable masks it, through
     * the SAME mask() the report advertises, and the mask is printed.
     */
    static boolean stable;

    private OneTripForEver() { }

    public static void main(String[] args) {
        stable = java.util.Arrays.asList(args).contains("--stable");
        System.out.println("mask     " + (stable
                ? "--stable ON  : " + ContextReport.MASK
                : "off  (--stable masks: " + ContextReport.MASK + ")"));
        System.out.printf("%-4s %-30s %s%n", "", "injection point", "what the desk got");
        holds("[A ]", "DeliveryRun run");
        asks("[B ]", "ObjectProvider<DeliveryRun> runs");
        holds("[A']", "DeliveryRun run");
        System.out.println();
        System.out.println("DeliveryRun objects this JVM constructed in total  " + DeliveryRun.built());
    }

    static void holds(String tag, String point) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Dispatch.HoldsIt.class)) {
            Dispatch.HoldsTheRun desk = ctx.getBean(Dispatch.HoldsTheRun.class);
            DeliveryRun t1 = desk.nextRun("Ravi");
            DeliveryRun t2 = desk.nextRun("Meera");
            report(tag, point, ctx, t1, t2);
        }
    }

    static void asks(String tag, String point) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Dispatch.AsksForIt.class)) {
            Dispatch.AsksEachTime desk = ctx.getBean(Dispatch.AsksEachTime.class);
            DeliveryRun t1 = desk.nextRun("Ravi");
            DeliveryRun t2 = desk.nextRun("Meera");
            report(tag, point, ctx, t1, t2);
        }
    }

    static void report(String tag, String point, AnnotationConfigApplicationContext ctx,
                       DeliveryRun t1, DeliveryRun t2) {
        System.out.println();
        System.out.printf("%s %s%n", tag, point);
        System.out.printf("  trip one == trip two                 %s%n", t1 == t2);
        String ids = String.format("@%s  @%s",
                Integer.toHexString(System.identityHashCode(t1)),
                Integer.toHexString(System.identityHashCode(t2)));
        System.out.printf("  identityHashCode of the two          %s%n",
                stable ? ContextReport.mask(ids) : ids);
        System.out.printf("  stops on the object trip two returned %s%n", t2.stops());
        System.out.printf("  scope in the definition              \"%s\"   isSingleton=%s%n",
                ctx.getBeanFactory().getBeanDefinition("deliveryRun").getScope(),
                ctx.getBeanFactory().getBeanDefinition("deliveryRun").isSingleton());
        System.out.printf("  the container is holding a singleton called deliveryRun  %s%n",
                ctx.getBeanFactory().containsSingleton("deliveryRun"));
    }
}
