package com.tiffinbox;

import org.springframework.context.annotation.*;
import org.springframework.context.event.EventListener;
import org.springframework.core.annotation.Order;

/** @Order on listeners - the same annotation that sorted an injected list two sections ago. Three runs, one sequence. */
public final class Ordered {
    private Ordered() { }
    public static class Listeners {
        @EventListener @Order(3) public void receipt(OrderPlaced e) { System.out.print(" receipt"); }
        @EventListener @Order(1) public void sms(OrderPlaced e)     { System.out.print(" sms"); }
        @EventListener @Order(2) public void loyalty(OrderPlaced e) { System.out.print(" loyalty"); }
    }
    /** The same three listeners with NO @Order (added after the section's RED review) - the A/B for "the numbers decide". */
    public static class Unnumbered {
        @EventListener public void receipt(OrderPlaced e) { System.out.print(" receipt"); }
        @EventListener public void sms(OrderPlaced e)     { System.out.print(" sms"); }
        @EventListener public void loyalty(OrderPlaced e) { System.out.print(" loyalty"); }
    }
    @Configuration static class Cfg { @Bean Listeners listeners() { return new Listeners(); } }
    @Configuration static class CfgUnnumbered { @Bean Unnumbered listeners() { return new Unnumbered(); } }
    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            for (int i = 1; i <= 3; i++) { System.out.print("  run " + i + ":"); ctx.publishEvent(new OrderPlaced("Ravi", 340)); System.out.println(); }
        }
        try (var ctx = new AnnotationConfigApplicationContext(CfgUnnumbered.class)) {
            System.out.print("  without @Order:"); ctx.publishEvent(new OrderPlaced("Ravi", 340)); System.out.println();
        }
    }
}
