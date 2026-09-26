package com.tiffinbox;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;

/**
 * The kitchen awards loyalty points by calling LoyaltyBook directly. Delete that edge: the kitchen must
 * publish OrderPlaced and a listener must award the points. Prove it with Edges - the kitchen's own
 * dependencies must print [] - and the points must still be 34.
 */
public class Loyalty {
    public static class LoyaltyBook { int points; void award(int total) { points += total / 10; } }

    public static class Kitchen {
        private final LoyaltyBook book;                                   // TODO: delete this edge
        public Kitchen(LoyaltyBook book) { this.book = book; }
        public void place(String c, int total) { book.award(total); }
    }

    @Configuration
    static class Cfg {
        @Bean LoyaltyBook loyaltyBook() { return new LoyaltyBook(); }
        @Bean Kitchen kitchen(LoyaltyBook b) { return new Kitchen(b); }
    }

    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            ctx.getBean(Kitchen.class).place("Ravi", 340);
            System.out.println("  points: " + ctx.getBean(LoyaltyBook.class).points + "   (want 34)");
            Edges.print(ctx, "kitchen");
        }
    }
}
