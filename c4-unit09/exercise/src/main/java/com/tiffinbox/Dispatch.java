package com.tiffinbox;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/** The dispatch desk. It starts clean and every trip is the same trip. */
public final class Dispatch {

    private Dispatch() { }

    public static final class HoldsTheRun {
        private final DeliveryRun run;
        public HoldsTheRun(DeliveryRun run) { this.run = run; }
        public DeliveryRun nextRun(String customer) { return run.stop(customer); }
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

        @Bean HoldsTheRun desk(DeliveryRun run) { return new HoldsTheRun(run); }
    }
}
