package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * A timing aspect - and the lesson is NOT the number. Three calls, and the program prints what the
 * aspect can see (signature, arguments, return value) beside a duration that differs every run.
 * The first call is also far slower than the third: a single duration is not a fact.
 */
public final class Timing {

    private Timing() { }

    @Aspect public static class Timer {
        @Around("execution(* com.tiffinbox.Billing.price(..))")
        public Object t(ProceedingJoinPoint p) throws Throwable {
            long t0 = System.nanoTime();
            Object r = p.proceed();
            System.out.printf("  %s(%s) -> %s   took %.3f ms%n", p.getSignature().getName(),
                    p.getArgs()[0], r, (System.nanoTime() - t0) / 1e6);
            return r;
        }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean Timer timer() { return new Timer(); } }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            for (int i = 0; i < 3; i++) b.price("Ravi");
        }
    }
}
