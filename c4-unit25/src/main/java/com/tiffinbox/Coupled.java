package com.tiffinbox;

import org.springframework.context.annotation.*;

/**
 * BEFORE. The kitchen holds the notifier and calls it. It feels necessary - how else would the customer
 * hear? - and it means the kitchen cannot be built, tested or changed without a phone gateway.
 */
public final class Coupled {
    private Coupled() { }

    public static class Kitchen {
        private final SmsNotifier sms;                                  // the edge this unit deletes
        public Kitchen(SmsNotifier sms) { this.sms = sms; }
        public void place(String customer, int total) {
            System.out.println("  [kitchen] cooking for " + customer);
            sms.orderIn(customer);
        }
    }

    @Configuration
    static class Cfg {
        @Bean SmsNotifier smsNotifier() { return new SmsNotifier(); }
        @Bean Kitchen kitchen(SmsNotifier s) { return new Kitchen(s); }
    }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            ctx.getBean(Kitchen.class).place("Ravi", 340);
            Edges.print(ctx, "kitchen");
        }
    }
}
