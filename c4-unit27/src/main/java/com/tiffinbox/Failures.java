package com.tiffinbox;

import java.lang.reflect.Method;
import java.util.concurrent.*;
import org.springframework.aop.interceptor.AsyncUncaughtExceptionHandler;
import org.springframework.context.annotation.*;
import org.springframework.scheduling.annotation.*;

/**
 * THE BREAK, and the skeleton had it half wrong: a void @Async that throws is NOT unlogged - Spring logs
 * it at SEVERE. What is true is that the CALLER never sees it. Two ways to get it back into code: return a
 * CompletableFuture, or install an AsyncUncaughtExceptionHandler.
 */
public final class Failures {
    private Failures() { }
    static final CountDownLatch handled = new CountDownLatch(1);
    public static class Kitchen {
        @Async public void burn() { throw new IllegalStateException("the oven caught fire"); }
        @Async public CompletableFuture<Integer> price() { throw new IllegalStateException("price failed"); }
    }
    @Configuration @EnableAsync static class Plain { @Bean Kitchen k() { return new Kitchen(); } }
    @Configuration @EnableAsync static class Handled implements AsyncConfigurer {
        @Bean Kitchen k() { return new Kitchen(); }
        @Override public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
            return (Throwable ex, Method m, Object... params) -> {
                System.out.println("  [handler] " + m.getName() + "() threw " + ex.getClass().getSimpleName() + ": " + ex.getMessage());
                handled.countDown();
            };
        }
    }
    public static void main(String[] a) throws Exception {
        boolean withHandler = a.length > 0 && a[0].equals("handler");
        try (var ctx = new AnnotationConfigApplicationContext(withHandler ? Handled.class : Plain.class)) {
            Kitchen k = ctx.getBean(Kitchen.class);
            k.burn();
            System.out.println("  [caller] burn() returned - the caller does not know");
            if (withHandler) handled.await(2, TimeUnit.SECONDS); else Thread.sleep(300);
            if (!withHandler) {
                try { k.price().get(); }
                catch (ExecutionException e) { System.out.println("  [caller] price().get() threw " + e.getClass().getSimpleName()
                        + ", cause " + e.getCause().getClass().getSimpleName() + ": " + e.getCause().getMessage()); }
            }
        }
    }
}
