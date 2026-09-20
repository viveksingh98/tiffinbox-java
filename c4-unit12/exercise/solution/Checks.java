package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;

/**
 * TiffinBox will not open without all three, and they are not interchangeable: the water has
 * to be on before the gas, and the gas before the power-hungry extractor fan. The routine
 * runs them in whatever order it was handed them.
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

    @Configuration
    public static class Ordered {
        @Bean @Order(3) Power power() { return new Power(); }
        @Bean @Order(1) Water water() { return new Water(); }
        @Bean @Order(2) Gas gas() { return new Gas(); }
        @Bean OpeningRoutine opening(List<StartupCheck> checks) { return new OpeningRoutine(checks); }
    }
}
