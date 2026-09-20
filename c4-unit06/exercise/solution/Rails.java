package com.tiffinbox;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * TiffinBox has TWO order rails, and this is the whole reason this unit has tension.
 *
 * <p>The kitchen rail cooks. The delivery rail carries. They are the same type, they are both
 * legitimately wanted, and NEITHER of them is the obvious default — which is exactly why
 * @Primary is the weakest of the three answers here and the unit says so.
 */
public final class Rails {

    private Rails() { }

    /** Wants the one that cooks. Names it. */
    public static class BillingService {
        private final OrderQueue kitchen;
        BillingService(@Qualifier("kitchenRail") OrderQueue kitchen) { this.kitchen = kitchen; }
        public int cooked() { return kitchen.cooked(); }
    }

    /** Wants the one that carries. Names it. */
    public static class DeliveryService {
        private final OrderQueue delivery;
        DeliveryService(@Qualifier("deliveryRail") OrderQueue delivery) { this.delivery = delivery; }
        public int carried() { return delivery.cooked(); }
    }

    /**
     * Wants BOTH, and does not care which is which — the answer most tutorials never mention.
     * A List of the interface, and a Map from bean name to bean.
     */
    public static class RailMonitor {
        private final List<OrderQueue> all;
        private final Map<String, OrderQueue> byName;
        RailMonitor(List<OrderQueue> all, Map<String, OrderQueue> byName) {
            this.all = all;
            this.byName = byName;
        }
        public int railCount() { return all.size(); }
        public List<String> names() { return byName.keySet().stream().sorted().toList(); }
    }

    @Configuration
    public static class Config {
        @Bean OrderQueue kitchenRail() { return new OrderQueue(3); }
        @Bean OrderQueue deliveryRail() { return new OrderQueue(2); }
        @Bean BillingService billingService(@Qualifier("kitchenRail") OrderQueue q) {
            return new BillingService(q);
        }
        @Bean DeliveryService deliveryService(@Qualifier("deliveryRail") OrderQueue q) {
            return new DeliveryService(q);
        }
        @Bean RailMonitor railMonitor(List<OrderQueue> all, Map<String, OrderQueue> byName) {
            return new RailMonitor(all, byName);
        }
    }

    /** The ambiguous version: one slot, two candidates, nothing to break the tie. */
    @Configuration
    public static class Ambiguous {
        @Bean OrderQueue kitchenRail() { return new OrderQueue(3); }
        @Bean OrderQueue deliveryRail() { return new OrderQueue(2); }
        @Bean Dashboard needsOne(OrderQueue anyRail, CustomerRepository repo) {
            return new Dashboard(repo);
        }
        @Bean Database database() throws Exception {
            Database db = new Database("jdbc:h2:mem:tiffinbox-u06;DB_CLOSE_DELAY=-1");
            db.createAndSeed();
            return db;
        }
        @Bean CustomerRepository customerRepository(Database db) { return new CustomerRepository(db); }
    }
}
