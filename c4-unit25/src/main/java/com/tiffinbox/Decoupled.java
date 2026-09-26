package com.tiffinbox;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;

/**
 * AFTER. The field is gone, the constructor parameter is gone, and SmsNotifier is not imported or named
 * anywhere in Kitchen. The kitchen announces what happened; whoever cares, listens.
 */
public final class Decoupled {
    private Decoupled() { }

    public static class Kitchen {
        private final ApplicationEventPublisher events;
        public Kitchen(ApplicationEventPublisher events) { this.events = events; }
        public void place(String customer, int total) {
            System.out.println("  [kitchen] cooking for " + customer + "  (on " + Thread.currentThread().getName() + ")");
            events.publishEvent(new OrderPlaced(customer, total));
            System.out.println("  [kitchen] publish returned");
        }
    }

    public static class SmsListener {
        private final SmsNotifier sms;
        public SmsListener(SmsNotifier sms) { this.sms = sms; }
        @EventListener public void on(OrderPlaced e) {
            System.out.print("  (on " + Thread.currentThread().getName() + ")");
            sms.orderIn(e.customer());
        }
    }

    public static class ReceiptListener {
        @EventListener public void on(OrderPlaced e) {
            System.out.println("  [receipt] " + e.customer() + " owes " + e.total() + "  (on " + Thread.currentThread().getName() + ")");
            if (e.customer().equals("nobody")) throw new IllegalStateException("receipt printer refused nobody");
        }
    }

    @Configuration
    static class Cfg {
        @Bean Kitchen kitchen(ApplicationEventPublisher p) { return new Kitchen(p); }
        @Bean SmsNotifier smsNotifier() { return new SmsNotifier(); }
        @Bean ReceiptListener receiptListener() { return new ReceiptListener(); }
        @Bean SmsListener smsListener(SmsNotifier s) { return new SmsListener(s); }
    }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            k.place("Ravi", 340);
            Edges.print(ctx, "kitchen");
            if (args.length > 0 && args[0].equals("break")) {
                System.out.println("an order for nobody:");
                try { k.place("nobody", 340); }
                catch (IllegalStateException ex) { System.out.println("  [caller ] got " + ex.getClass().getSimpleName() + ": " + ex.getMessage()); }
            }
        }
    }
}
