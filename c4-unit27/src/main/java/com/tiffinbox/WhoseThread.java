package com.tiffinbox;

import java.util.concurrent.*;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/** One annotation, and the method returns before it runs. Two thread names are the whole claim. */
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
        }
    }
}
