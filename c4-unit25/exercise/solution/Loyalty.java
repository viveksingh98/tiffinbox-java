package com.tiffinbox;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;

/** Solution: the kitchen publishes; a listener awards. The kitchen no longer knows the book exists. */
public class Loyalty {
    public static class LoyaltyBook { int points; void award(int total) { points += total / 10; } }

    public static class Kitchen {
        private final ApplicationEventPublisher events;
        public Kitchen(ApplicationEventPublisher events) { this.events = events; }
        public void place(String c, int total) { events.publishEvent(new OrderPlaced(c, total)); }
    }

    public static class LoyaltyListener {
        private final LoyaltyBook book;
        public LoyaltyListener(LoyaltyBook book) { this.book = book; }
        @EventListener public void on(OrderPlaced e) { book.award(e.total()); }
    }

    @Configuration
    static class Cfg {
        @Bean LoyaltyBook loyaltyBook() { return new LoyaltyBook(); }
        @Bean Kitchen kitchen(ApplicationEventPublisher p) { return new Kitchen(p); }
        @Bean LoyaltyListener loyaltyListener(LoyaltyBook b) { return new LoyaltyListener(b); }
    }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            ctx.getBean(Kitchen.class).place("Ravi", 340);
            System.out.println("  points: " + ctx.getBean(LoyaltyBook.class).points + "   (want 34)");
            Edges.print(ctx, "kitchen");
        }
    }
}
