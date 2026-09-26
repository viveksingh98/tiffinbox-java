package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * Only @Around holds a ProceedingJoinPoint, so only @Around can do these three. Each is DEMONSTRATED,
 * because "@Around can change the arguments" is a claim and a run is a proof.
 */
public final class ThreePowers {

    private ThreePowers() { }
    static final String P = "execution(* com.tiffinbox.Billing.price(..))";

    @Aspect public static class SkipIt {
        @Around(P) public Object a(ProceedingJoinPoint pjp) { return -1; }                      // never proceeds
    }
    @Aspect public static class ChangeArgs {
        @Around(P) public Object a(ProceedingJoinPoint pjp) throws Throwable { return pjp.proceed(new Object[]{"SOMEBODY ELSE"}); }
    }
    @Aspect public static class ChangeReturn {
        @Around(P) public Object a(ProceedingJoinPoint pjp) throws Throwable { return ((int) pjp.proceed()) * 2; }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } }

    static void run(String label, Class<?> aspect) {
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.register(Cfg.class, aspect); ctx.refresh();
            System.out.println("  " + label + ":");
            System.out.println("    caller got: " + ctx.getBean(Billing.class).price("Ravi"));
        }
    }

    public static void main(String[] args) {
        run("skip the call", SkipIt.class);
        run("change the arguments", ChangeArgs.class);
        run("change the return value", ChangeReturn.class);
    }
}
