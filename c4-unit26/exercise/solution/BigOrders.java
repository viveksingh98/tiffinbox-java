package com.tiffinbox;

import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;

/**
 * Solution: "#a0.total > 500" names the first argument by POSITION, which Spring can always see - no build
 * setting needed. The one build setting that would ALSO have fixed "#order.total > 500": compile with
 * -parameters (Spring Boot's parent POM turns it on), so the parameter's NAME is available to reflection.
 * A 900 order gets the call; a 340 order does not.
 */
public class BigOrders {
    static int calls;
    public static class Manager {
        @EventListener(condition = "#a0.total > 500")                       // the first argument, by position
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
