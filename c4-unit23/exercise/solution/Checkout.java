package com.tiffinbox;

import org.springframework.context.annotation.*;

/** Solution: the inner call now crosses a SECOND bean's proxy. One more class, and a better design. */
public class Checkout {
    public static class Pricer { public int price(String item) { return 170; } }
    public static class Till {
        private final Pricer pricer;
        public Till(Pricer pricer) { this.pricer = pricer; }
        public int checkout(String... items) {
            int total = 0;
            for (String i : items) total += pricer.price(i);
            return total;
        }
    }
    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Pricer pricer() { return new Pricer(); } @Bean Till till(Pricer p) { return new Till(p); } @Bean Counted counted() { return new Counted(); } }
    public static void main(String[] a) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Counted.hits = 0;
            int t = ctx.getBean(Till.class).checkout("lunch box", "dinner box");
            System.out.println("total " + t + " | advice ran " + Counted.hits + "   (want 2)");
        }
    }
}
