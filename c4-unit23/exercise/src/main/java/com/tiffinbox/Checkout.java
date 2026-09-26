package com.tiffinbox;

import org.springframework.context.annotation.*;

/**
 * checkout() prices each item by calling price() - and the pricing aspect never sees those calls.
 * Fix it the RIGHT way (extract a second bean), not with self-injection or AopContext, and prove it:
 * advice must run once per item.
 */
public class Checkout {
    public static class Till {
        public int price(String item) { return 170; }
        public int checkout(String... items) {
            int total = 0;
            for (String i : items) total += price(i);        // TODO: the trap
            return total;
        }
    }
    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Till till() { return new Till(); } @Bean Counted counted() { return new Counted(); } }
    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Counted.hits = 0;
            int t = ctx.getBean(Till.class).checkout("lunch box", "dinner box");
            System.out.println("total " + t + " | advice ran " + Counted.hits + "   (want 2)");
        }
    }
}
