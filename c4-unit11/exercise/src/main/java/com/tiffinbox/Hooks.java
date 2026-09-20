package com.tiffinbox;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Every price list is supposed to come back frozen, so nothing can change a price after
 * startup. The context starts, exit code 0, and one of them is still writable.
 */
public final class Hooks {

    private Hooks() { }

    public static class Freezer implements BeanPostProcessor {
        @Override public Object postProcessAfterInitialization(Object bean, String name) {
            if (bean instanceof PriceList pl && !(bean instanceof FrozenPriceList)) {
                return new FrozenPriceList(pl);
            }
            return bean;
        }
    }

    /** A second post-processor. It wants a price list to compare the others against. */
    public static class Auditor implements BeanPostProcessor {
        private final PriceList baseline;
        public Auditor(PriceList baseline) { this.baseline = baseline; }
    }

    @Configuration
    public static class Config {
        @Bean static Freezer freezer() { return new Freezer(); }

        @Bean PriceList baselinePrices() { return new PriceList().set("thali", 12000); }

        @Bean PriceList kitchenPrices() { return new PriceList().set("thali", 12500); }

        @Bean static Auditor auditor(@Qualifier("baselinePrices") PriceList baseline) {
            return new Auditor(baseline);
        }
    }
}
