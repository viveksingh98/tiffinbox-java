package com.tiffinbox;

import java.util.logging.Level;
import java.util.logging.Logger;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

/**
 * WAY OUT ONE, measured - and measured as A/B/A' in ONE session, which contract 2c makes
 * mandatory for every flipped-attribute claim.
 *
 * <p>The two configuration classes below differ by EXACTLY ONE TOKEN: NoPrimary has no
 * &#64;Primary and OnePrimary has it on kitchenRail. Nothing else on either page is different -
 * same two rails, same cook counts, same injection point naming neither. That is what makes
 * the flip the only candidate explanation, and it is why both classes live in this one file
 * where a reader can diff them with their eyes.
 *
 * <p>A' is not ceremony. With two captures a viewer cannot tell "the annotation caused it"
 * from "the second run differed". A' is the FIRST context opened a second time, in the same
 * JVM, after B - so the three rows below are one capture with one md5, and A' reproducing A
 * is visible on screen rather than asserted by comparing two hashes.
 *
 * <p>The evidence in B is an identity printed BOTH ways in one capture (contract 2a rank 1,
 * 2b): the rail needsOne got IS kitchenRail and IS NOT deliveryRail. The counts either side of
 * it are derived off the bean definitions - isPrimary() on the definition, never asserted.
 *
 * <p>A and A' do not start. Their rows are still DERIVED: a failed refresh leaves the bean
 * DEFINITIONS registered (registration happens before instantiation), so the @Primary count is
 * read off the same definitions, and the container's own answer is read off the exception it
 * threw. The exit code of a caught failure is this program's, not the container's, so the
 * exit-1 receipt for this failure lives where it is honest: BreakAmbiguous, on slide 1.
 *
 * <p>And ONE line of the container's output is turned off, which this program says on its own
 * first line rather than in a comment nobody reads. A cancelled refresh is logged through
 * java.util.logging, and that record carries a TIMESTAMP - the one token in this capture that
 * cannot be reproduced, and therefore cannot be hashed. The record is a second copy of the
 * exception this program already caught and prints below, word for word, so silencing it
 * removes a duplicate and no evidence. Where the JUL record IS the lesson, it is on screen
 * with its timestamp chipped as varying: unit 03's slide 4 and this unit's slide 1.
 */
public final class PrimaryPicks {

    private PrimaryPicks() { }

    /** Holds whatever the container decided to hand it. */
    public static class NeedsOne {
        final OrderQueue got;
        NeedsOne(OrderQueue got) { this.got = got; }
    }

    /** CASE A - no tie-breaker. One slot, two candidates, nothing marked. */
    @Configuration
    public static class NoPrimary {
        @Bean OrderQueue kitchenRail() { return new OrderQueue(3); }
        @Bean OrderQueue deliveryRail() { return new OrderQueue(2); }
        /** parameter 0 names NEITHER rail. */
        @Bean NeedsOne needsOne(OrderQueue anyRail) { return new NeedsOne(anyRail); }
    }

    /** CASE B - ONE annotation added. Nothing else on this page is different. */
    @Configuration
    public static class OnePrimary {
        @Primary @Bean OrderQueue kitchenRail() { return new OrderQueue(3); }
        @Bean OrderQueue deliveryRail() { return new OrderQueue(2); }
        /** parameter 0 names NEITHER rail. */
        @Bean NeedsOne needsOne(OrderQueue anyRail) { return new NeedsOne(anyRail); }
    }

    /** One run of one configuration class, and every field on it is derived by that run. */
    private record Run(int rails, int primary, String answer, String detail) { }

    /** The one thing this program silences, and it is printed, every run. */
    static final String JUL = "the container's own WARNING for the cancelled refreshes - "
            + "a duplicate of the exception printed below, plus a timestamp";

    public static void main(String[] args) {
        Logger.getLogger(AnnotationConfigApplicationContext.class.getName()).setLevel(Level.OFF);
        System.out.println("jul off  " + JUL);
        System.out.println();
        // Run order is A, B, A' - three contexts, this JVM, this session. The two blocks are
        // PRINTED in teaching order afterwards, which is why the rows are collected first.
        Run a = open(NoPrimary.class);
        Run b = open(OnePrimary.class);
        Run aPrime = open(NoPrimary.class);

        // [B] in full: the identity both ways, with the derived counts either side of it.
        System.out.println("beans of type OrderQueue        " + b.rails());
        System.out.println("candidates declared @Primary    " + b.primary());
        System.out.println("the context started             yes, and it named nothing");
        System.out.println("needsOne got == kitchenRail     " + b.detail().split("\\|")[0]);
        System.out.println("needsOne got == deliveryRail    " + b.detail().split("\\|")[1]);
        System.out.println("read at the injection point     nothing - parameter 0 says OrderQueue");
        System.out.println();
        System.out.println("A/B/A'  the same annotation added and removed, three contexts, one session");
        row("[A ] no @Primary            ", a);
        row("[B ] @Primary on kitchenRail", b);
        row("[A'] @Primary removed again ", aPrime);
    }

    private static void row(String label, Run r) {
        System.out.printf("%s  rails %d  @Primary %d  %-32s %s%n",
                label, r.rails(), r.primary(), r.answer(), r.detail().replace("|", " / "));
    }

    /**
     * Opens one configuration class and DERIVES every row off what came back. Registration
     * happens before instantiation, so the definitions - and therefore the @Primary count -
     * are readable even when refresh() throws.
     */
    private static Run open(Class<?> config) {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        ctx.register(config);
        RuntimeException failure = null;
        try {
            ctx.refresh();
        } catch (RuntimeException e) {
            failure = e;
        }
        try {
            ConfigurableListableBeanFactory bf = ctx.getBeanFactory();
            String[] rails = bf.getBeanNamesForType(OrderQueue.class);
            if (rails.length != 2) {
                die("expected exactly the two rails and found " + rails.length
                        + " - the comparison below has nothing to compare.");
            }
            int primary = 0;
            for (String n : rails) {
                if (bf.getBeanDefinition(n).isPrimary()) {
                    primary++;
                }
            }
            if (failure != null) {
                Throwable root = failure;
                while (root.getCause() != null) {
                    root = root.getCause();
                }
                String first = root.getMessage().split("\\R")[0];
                return new Run(rails.length, primary, root.getClass().getSimpleName(),
                        first.substring(first.indexOf("expected")));
            }
            OrderQueue got = ctx.getBean(NeedsOne.class).got;
            return new Run(rails.length, primary, "started, and it named nothing",
                    (got == ctx.getBean("kitchenRail")) + "|" + (got == ctx.getBean("deliveryRail")));
        } finally {
            ctx.close();
        }
    }

    private static void die(String why) {
        System.out.flush();
        System.err.println("PrimaryPicks: " + why);
        System.exit(2);
    }
}
