package com.tiffinbox;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The break, and the point is not the log line — it is what the log line is about.
 *
 * <p>A BeanPostProcessor has to exist before the beans it processes. So anything it depends on
 * is built early, and a bean built that early has missed the queue of post-processors it was
 * supposed to go through. The container says so and carries on with exit 0. The consequence is
 * a bean that quietly did not get the treatment every other bean of its type got.
 */
public final class BreakEarlyReference {

    private BreakEarlyReference() { }

    /** The same freezer as the working demo: every PriceList comes back frozen. */
    public static class Freezer implements BeanPostProcessor {
        @Override public Object postProcessAfterInitialization(Object bean, String name) {
            if (bean instanceof PriceList pl && !(bean instanceof FrozenPriceList)) {
                return new FrozenPriceList(pl);
            }
            return bean;
        }
    }

    /** A second post-processor that needs a price list of its own to compare against. */
    public static class Auditor implements BeanPostProcessor {
        private final PriceList baseline;
        public Auditor(PriceList baseline) { this.baseline = baseline; }
        @Override public Object postProcessAfterInitialization(Object bean, String name) {
            return bean;
        }
    }

    @Configuration
    public static class Config {
        @Bean static Freezer freezer() { return new Freezer(); }

        @Bean PriceList baselinePrices() { return new PriceList().set("thali", 12000); }

        @Bean PriceList kitchenPrices() { return new PriceList().set("thali", 12500); }

        /** Takes a bean. That one parameter is the whole defect. */
        @Bean static Auditor auditor(@Qualifier("baselinePrices") PriceList baseline) {
            return new Auditor(baseline);
        }
    }

    public static void main(String[] args) {
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(Config.class)) {
            System.out.println();
            System.out.println("refresh                started, and nothing threw");
            for (String n : new String[] {"kitchenPrices", "baselinePrices"}) {
                PriceList p = ctx.getBean(n, PriceList.class);
                String writable;
                try {
                    p.set("probe", 1);
                    writable = "WRITABLE — it never went through the freezer";
                } catch (UnsupportedOperationException e) {
                    writable = "frozen";
                }
                System.out.printf("  %-16s %-34s %s%n", n, p.getClass().getSimpleName(), writable);
            }
            long frozen = java.util.Arrays.stream(ctx.getBeanNamesForType(PriceList.class))
                    .filter(n -> ctx.getBean(n) instanceof FrozenPriceList).count();
            System.out.printf("  price lists that went through the post-processor   %d of %d%n",
                    frozen, ctx.getBeanNamesForType(PriceList.class).length);
        }
    }
}
