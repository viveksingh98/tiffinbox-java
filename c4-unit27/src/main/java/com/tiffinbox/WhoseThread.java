package com.tiffinbox;

import java.util.concurrent.*;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * One annotation (with @EnableAsync on the configuration), and the method returns before it runs. Two
 * thread names are the whole claim. Only void or Future-returning methods, called from OUTSIDE the bean:
 * the last two rows show a self-invocation (runs on main) and a String-returning method (the call throws).
 */
public final class WhoseThread {
    private WhoseThread() { }
    static final CountDownLatch returned = new CountDownLatch(1), finished = new CountDownLatch(1);
    public static class Kitchen {
        @Async public void cook(String c) throws InterruptedException {
            returned.await(2, TimeUnit.SECONDS);                       // wait until the caller has moved on
            System.out.println("  [cook ] cooking for " + c + " on " + T.name());
            finished.countDown();
        }
        @Async public void inner(String c) { System.out.println("  [inner] on " + T.name()); }
        @Async public String price(String c) { return "340"; }          // not void, not a Future (RED 2026-09-26)
        public void cookViaSelf(String c) { inner(c); }                 // this.inner() - never passes the proxy
    }
    @Configuration @EnableAsync static class Cfg { @Bean Kitchen kitchen() { return new Kitchen(); } }
    public static void main(String[] a) throws Exception {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            System.out.println("  [caller] on " + T.name());
            k.cook("Ravi");
            System.out.println("  [caller] cook() returned");
            returned.countDown(); finished.await(3, TimeUnit.SECONDS);
            System.out.println("self-invocation:");
            k.cookViaSelf("Ravi");
            System.out.println("an @Async method that returns a String:");
            try { System.out.println("  [caller] got " + k.price("Ravi")); }
            catch (IllegalArgumentException e) { System.out.println("  [caller] " + e.getClass().getSimpleName() + ": " + e.getMessage()); }
        }
    }
}
