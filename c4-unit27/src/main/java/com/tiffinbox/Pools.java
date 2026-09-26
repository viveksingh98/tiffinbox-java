package com.tiffinbox;

import java.util.*;
import java.util.concurrent.*;
import org.springframework.context.annotation.*;
import org.springframework.core.task.SimpleAsyncTaskExecutor;
import org.springframework.scheduling.annotation.*;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/** Twenty tasks, three executors: the default, a sized pool, and virtual threads. Count distinct threads. */
public final class Pools {
    private Pools() { }
    static final Set<String> seen = ConcurrentHashMap.newKeySet();
    static CountDownLatch done;
    public static class Kitchen {
        @Async public void cook() {
            seen.add(Thread.currentThread().getName() + (Thread.currentThread().isVirtual() ? " [virtual]" : " [platform]") + "#" + Thread.currentThread().threadId());
            try { Thread.sleep(40); } catch (InterruptedException e) { }
            done.countDown();
        }
    }
    @Configuration @EnableAsync static class Default { @Bean Kitchen k() { return new Kitchen(); } }
    @Configuration @EnableAsync static class Sized {
        @Bean Kitchen k() { return new Kitchen(); }
        @Bean ThreadPoolTaskExecutor taskExecutor() {
            ThreadPoolTaskExecutor e = new ThreadPoolTaskExecutor();
            e.setCorePoolSize(2); e.setMaxPoolSize(2); e.setQueueCapacity(50);
            e.setThreadNamePrefix("kitchen-"); e.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
            return e;
        }
    }
    @Configuration @EnableAsync static class Virtual {
        @Bean Kitchen k() { return new Kitchen(); }
        @Bean SimpleAsyncTaskExecutor taskExecutor() {
            SimpleAsyncTaskExecutor e = new SimpleAsyncTaskExecutor("vkitchen-"); e.setVirtualThreads(true); return e;
        }
    }
    static void run(String label, Class<?> cfg) throws Exception {
        seen.clear(); done = new CountDownLatch(20);
        try (var ctx = new AnnotationConfigApplicationContext(cfg)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            for (int i = 0; i < 20; i++) k.cook();
            done.await(5, TimeUnit.SECONDS);
            String sample = seen.iterator().next().replaceAll("#\\d+$", "").replaceAll("\\d+ \\[", "<n> [");
            System.out.printf("  %-34s 20 tasks -> %2d distinct threads   e.g. %s%n", label, seen.size(), sample);
        }
    }
    public static void main(String[] a) throws Exception {
        run("the default (no executor bean)", Default.class);
        run("ThreadPoolTaskExecutor, 2 threads", Sized.class);
        run("virtual threads", Virtual.class);
    }
}
