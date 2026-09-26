package com.tiffinbox;

import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;

/**
 * Orders over 500 get a call from the manager. This listener was copied from the documentation, and the
 * whole kitchen falls over on the very first order. Fix the condition WITHOUT touching the build file, so
 * a 900 order gets the call and a 340 order does not.
 */
public class BigOrders {
    static int calls;
    public static class Manager {
        @EventListener(condition = "#order.total > 500")                    // TODO
        public void call(OrderPlaced order) { calls++; }
    }
    @Configuration static class Cfg { @Bean Manager manager() { return new Manager(); } }
    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            ctx.publishEvent(new OrderPlaced("Ravi", 340));
            ctx.publishEvent(new OrderPlaced("Asha", 900));
            System.out.println("  manager calls: " + calls + "   (want 1)");
        }
    }
}
