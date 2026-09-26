package com.tiffinbox;

import java.util.*;
import java.util.concurrent.*;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * Solution. The bean is named taskExecutor, which is the name @EnableAsync looks for. Give the kitchen a
 * pool of exactly 3 threads named "receipts-", and prove it: 30 receipts must run on 3 distinct threads.
 */
public class Receipts {
    static final Set<String> seen = ConcurrentHashMap.newKeySet();
    static final CountDownLatch done = new CountDownLatch(30);
    public static class Printer {
        @Async public void print(int n) { seen.add(Thread.currentThread().getName()); try { Thread.sleep(20); } catch (InterruptedException e) { } done.countDown(); }
    }
    @Configuration @EnableAsync
    static class Cfg {
        @Bean Printer printer() { return new Printer(); }
        @Bean org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor taskExecutor() {
            var e = new org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor();
            e.setCorePoolSize(3); e.setMaxPoolSize(3); e.setQueueCapacity(100);
            e.setThreadNamePrefix("receipts-");
            return e;
        }
    }
    public static void main(String[] a) throws Exception {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Printer p = ctx.getBean(Printer.class);
            for (int i = 0; i < 30; i++) p.print(i);
            done.await(5, TimeUnit.SECONDS);
            System.out.println("  30 receipts on " + seen.size() + " distinct threads   (want 3)   e.g. "
                    + seen.iterator().next().replaceAll("\\d+$", "<n>"));
        }
    }
}
