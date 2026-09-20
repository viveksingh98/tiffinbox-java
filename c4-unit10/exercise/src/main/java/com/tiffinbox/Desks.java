package com.tiffinbox;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The billing desk and the delivery desk, wired through setters. The context starts, nothing
 * is logged, and the two of them point at each other for ever.
 */
public final class Desks {

    private Desks() { }

    public static class Billing {
        Delivery delivery;
        @Autowired public void setDelivery(Delivery d) { this.delivery = d; }
        public int billFor(String c) { return 300 + delivery.chargeFor(c); }
    }

    public static class Delivery {
        Billing billing;
        @Autowired public void setBilling(Billing b) { this.billing = b; }
        public int chargeFor(String c) { return 40; }
    }

    @Configuration
    public static class Config {
        @Bean Billing billing() { return new Billing(); }
        @Bean Delivery delivery() { return new Delivery(); }
    }
}
