package com.tiffinbox;

import org.springframework.aop.framework.AopContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.*;

/**
 * Three ways out of the trap, each RUN - and each has a price, printed with it.
 */
public final class WaysOut {

    private WaysOut() { }

    /** 1. EXTRACT: the inner call goes to a SECOND bean, so it crosses a proxy. */
    public static class Pricer { public int price(String c) { return 340; } }
    public static class ExtractedBilling {
        private final Pricer pricer;
        public ExtractedBilling(Pricer pricer) { this.pricer = pricer; }
        public int priceTwice(String c) { return pricer.price(c) + pricer.price(c); }
    }

    /** 2. SELF-INJECTION: the bean asks for its own proxy and calls through it. */
    public static class SelfInjected {
        @Autowired @Lazy SelfInjected self;
        public int price(String c) { return 340; }
        public int priceTwice(String c) { return self.price(c) + self.price(c); }
    }

    /** 3. AopContext: ask Spring for the proxy currently in charge of this call. */
    public static class ContextBilling {
        public int price(String c) { return 340; }
        public int priceTwice(String c) {
            ContextBilling me = (ContextBilling) AopContext.currentProxy();
            return me.price(c) + me.price(c);
        }
    }

    @Configuration @EnableAspectJAutoProxy(exposeProxy = true)
    static class Cfg {
        @Bean Pricer pricer() { return new Pricer(); }
        @Bean ExtractedBilling extracted(Pricer p) { return new ExtractedBilling(p); }
        @Bean SelfInjected selfInjected() { return new SelfInjected(); }
        @Bean ContextBilling contextBilling() { return new ContextBilling(); }
        @Bean Counted counted() { return new Counted(); }
    }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Counted.hits = 0; ctx.getBean(ExtractedBilling.class).priceTwice("Ravi");
            System.out.println("  1. extract to a second bean   : advice ran " + Counted.hits + "   cost: one more class - and the design is better for it");
            Counted.hits = 0; ctx.getBean(SelfInjected.class).priceTwice("Ravi");
            System.out.println("  2. self-injection             : advice ran " + Counted.hits + "   cost: a bean that depends on itself");
            Counted.hits = 0; ctx.getBean(ContextBilling.class).priceTwice("Ravi");
            System.out.println("  3. AopContext.currentProxy()  : advice ran " + Counted.hits + "   cost: Spring inside your business code, and exposeProxy must be on");
        }
    }
}
