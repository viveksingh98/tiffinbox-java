package com.tiffinbox;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;

/**
 * A needs B and B needs A — the real shape it takes in an application rather than a toy.
 *
 * <p>The billing desk needs the delivery desk to price a delivery. The delivery desk needs the
 * billing desk to know whether this customer is on a plan. Both are true requirements, and
 * neither developer did anything obviously wrong.
 */
public final class Cycle {

    private Cycle() { }

    // ---------------------------------------------------- [1] both through constructors ----

    public static class BillingDesk {
        private final DeliveryDesk delivery;
        public BillingDesk(DeliveryDesk delivery) { this.delivery = delivery; }
        public int billFor(String customer) { return 300 + delivery.chargeFor(customer); }
        /** What is actually in the field — which is not always what the type says. */
        public Object held() { return delivery; }
    }

    public static class DeliveryDesk {
        private final BillingDesk billing;
        public DeliveryDesk(BillingDesk billing) { this.billing = billing; }
        public int chargeFor(String customer) { return 40; }
    }

    @Configuration
    public static class BothConstructors {
        @Bean BillingDesk billingDesk(DeliveryDesk d) { return new BillingDesk(d); }
        @Bean DeliveryDesk deliveryDesk(BillingDesk b) { return new DeliveryDesk(b); }
    }

    // ------------------------------------------------- [2] one side marked @Lazy ----

    @Configuration
    public static class OneSideLazy {
        @Bean BillingDesk billingDesk(@Lazy DeliveryDesk d) { return new BillingDesk(d); }
        @Bean DeliveryDesk deliveryDesk(BillingDesk b) { return new DeliveryDesk(b); }
    }

    // ------------------------------------------------- [3] one side through a setter ----

    public static class SetterBilling {
        SetterDelivery delivery;
        @Autowired public void setDelivery(SetterDelivery d) { this.delivery = d; }
    }

    public static class SetterDelivery {
        SetterBilling billing;
        @Autowired public void setBilling(SetterBilling b) { this.billing = b; }
    }

    @Configuration
    public static class BothSetters {
        @Bean SetterBilling setterBilling() { return new SetterBilling(); }
        @Bean SetterDelivery setterDelivery() { return new SetterDelivery(); }
    }

    // ------------------------------------------------------------------ [4] the cure ----

    /** What both desks actually wanted: the numbers, in one place, needing neither of them. */
    public static class Tariff {
        public int deliveryCharge(String customer) { return 40; }
        public int mealPrice(String customer) { return 300; }
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
    public static class Cured {
        @Bean Tariff tariff() { return new Tariff(); }
        @Bean Billing billing(Tariff t) { return new Billing(t); }
        @Bean Delivery delivery(Tariff t) { return new Delivery(t); }
    }
}
