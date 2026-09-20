package com.tiffinbox;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * THE ANSWER, and it is not an annotation. The two desks never wanted each other — they wanted
 * the numbers. Extract the numbers and the cycle is not bandaged, it is gone: both desks now
 * take what they need through a constructor, and the field that can be null has disappeared
 * with it.
 */
public final class Desks {

    private Desks() { }

    /** What both desks actually wanted. It needs neither of them. */
    public static class Tariff {
        public int mealPrice(String c) { return 300; }
        public int deliveryCharge(String c) { return 40; }
    }

    public static class Billing {
        private final Tariff tariff;
        public Billing(Tariff tariff) { this.tariff = tariff; }
        public int billFor(String c) { return tariff.mealPrice(c) + tariff.deliveryCharge(c); }
    }

    public static class Delivery {
        private final Tariff tariff;
        public Delivery(Tariff tariff) { this.tariff = tariff; }
        public int chargeFor(String c) { return tariff.deliveryCharge(c); }
    }

    @Configuration
    public static class Config {
        @Bean Tariff tariff() { return new Tariff(); }
        @Bean Billing billing(Tariff t) { return new Billing(t); }
        @Bean Delivery delivery(Tariff t) { return new Delivery(t); }
    }
}
