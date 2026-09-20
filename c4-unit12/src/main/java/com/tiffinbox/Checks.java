package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;

/**
 * The three startup checks, and the one thing that runs them.
 *
 * <p>[A] and [A'] declare them with no order at all. [B] is the same file with one annotation
 * added to each @Bean method and nothing else touched.
 */
public final class Checks {

    private Checks() { }

    public static final class Power implements StartupCheck {
        public Power() { StartupCheck.built("power"); }
        @Override public String name() { return "power"; }
    }

    public static final class Water implements StartupCheck {
        public Water() { StartupCheck.built("water"); }
        @Override public String name() { return "water"; }
    }

    public static final class Gas implements StartupCheck {
        public Gas() { StartupCheck.built("gas"); }
        @Override public String name() { return "gas"; }
    }

    /** Runs whatever it is handed, in the order it was handed them. */
    public static final class OpeningRoutine {
        private final List<StartupCheck> checks;
        public OpeningRoutine(List<StartupCheck> checks) { this.checks = checks; }
        public List<String> runAll() {
            List<String> out = new ArrayList<>();
            for (StartupCheck c : checks) {
                out.add(c.name());
            }
            return out;
        }
    }

    /** [A] / [A'] — nothing says anything about order. */
    @Configuration
    public static class NoOrder {
        @Bean Power power() { return new Power(); }
        @Bean Water water() { return new Water(); }
        @Bean Gas gas() { return new Gas(); }
        @Bean OpeningRoutine opening(List<StartupCheck> checks) { return new OpeningRoutine(checks); }
    }

    /** [B] — three annotations added. The methods are in the SAME order as above. */
    @Configuration
    public static class Ordered {
        @Bean @Order(3) Power power() { return new Power(); }
        @Bean @Order(1) Water water() { return new Water(); }
        @Bean @Order(2) Gas gas() { return new Gas(); }
        @Bean OpeningRoutine opening(List<StartupCheck> checks) { return new OpeningRoutine(checks); }
    }
}
