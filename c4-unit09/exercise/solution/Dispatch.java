package com.tiffinbox;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/**
 * THE ANSWER. The injection point changed and nothing else. The desk no longer asks for a
 * DeliveryRun; it asks for a WAY TO GET one, and asks again on every trip.
 *
 * <p>DeliveryRun is untouched — the scope was never the problem. The problem was that a
 * singleton is injected once, so whatever it was handed is what it keeps for ever.
 */
public final class Dispatch {

    private Dispatch() { }

    public static final class HoldsTheRun {
        private final ObjectProvider<DeliveryRun> runs;
        public HoldsTheRun(ObjectProvider<DeliveryRun> runs) { this.runs = runs; }
        public DeliveryRun nextRun(String customer) { return runs.getObject().stop(customer); }
    }

    public static final class AsksEachTime {
        private final ObjectProvider<DeliveryRun> runs;
        public AsksEachTime(ObjectProvider<DeliveryRun> runs) { this.runs = runs; }
        public DeliveryRun nextRun(String customer) { return runs.getObject().stop(customer); }
    }

    @Configuration
    public static class HoldsIt {
        @Bean @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
        DeliveryRun deliveryRun() { return new DeliveryRun(); }

        @Bean HoldsTheRun desk(ObjectProvider<DeliveryRun> runs) { return new HoldsTheRun(runs); }
    }
}
