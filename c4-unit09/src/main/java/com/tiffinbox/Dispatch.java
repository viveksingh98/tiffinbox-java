package com.tiffinbox;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/** The two desks. One attribute of difference between them, and it is at the INJECTION POINT. */
public final class Dispatch {

    private Dispatch() { }

    /** [A] and [A'] — the desk asks for a DeliveryRun and keeps what it was handed. */
    public static final class HoldsTheRun {
        private final DeliveryRun run;
        public HoldsTheRun(DeliveryRun run) { this.run = run; }
        public DeliveryRun nextRun(String customer) { return run.stop(customer); }
    }

    /** [B] — the desk asks for a WAY TO GET a DeliveryRun, and asks again each trip. */
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

    @Configuration
    public static class AsksForIt {
        @Bean @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
        DeliveryRun deliveryRun() { return new DeliveryRun(); }

        @Bean AsksEachTime desk(ObjectProvider<DeliveryRun> runs) { return new AsksEachTime(runs); }
    }
}
