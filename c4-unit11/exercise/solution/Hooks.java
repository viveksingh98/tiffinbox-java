package com.tiffinbox;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * THE ANSWER: the auditor stops being HANDED a bean and starts being handed a way to get one.
 *
 * <p>A BeanPostProcessor has to exist before the beans it processes, so any bean it takes as a
 * parameter is dragged forward and built before the post-processors are all in place — which
 * is exactly what the container's warning was about. An ObjectProvider is not a bean; it is a
 * handle. Nothing is built early, the baseline goes through the queue like everything else,
 * and the auditor gets it the first time it actually asks.
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

    public static class Auditor implements BeanPostProcessor {
        private final ObjectProvider<PriceList> baseline;
        public Auditor(ObjectProvider<PriceList> baseline) { this.baseline = baseline; }
    }

    @Configuration
    public static class Config {
        @Bean static Freezer freezer() { return new Freezer(); }

        @Bean PriceList baselinePrices() { return new PriceList().set("thali", 12000); }

        @Bean PriceList kitchenPrices() { return new PriceList().set("thali", 12500); }

        @Bean static Auditor auditor(ObjectProvider<PriceList> baseline) {
            return new Auditor(baseline);
        }
    }
}
