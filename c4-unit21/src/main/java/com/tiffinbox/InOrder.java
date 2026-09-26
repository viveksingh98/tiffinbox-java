package com.tiffinbox;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * All five kinds of advice on ONE call, in the order they actually fire - then the same call made to
 * throw, so @AfterThrowing replaces @AfterReturning and the difference is a real exception, not a claim.
 */
public final class InOrder {

    private InOrder() { }

    @Aspect
    public static class Every {
        static final String P = "execution(* com.tiffinbox.Billing.price(..))";
        @Around(P) public Object around(ProceedingJoinPoint pjp) throws Throwable {
            System.out.println("    @Around  (entering)");
            try { return pjp.proceed(); } finally { System.out.println("    @Around  (leaving)"); }
        }
        @Before(P)         public void before()        { System.out.println("    @Before"); }
        @After(P)          public void after()         { System.out.println("    @After"); }
        @AfterReturning(P) public void returned()      { System.out.println("    @AfterReturning"); }
        @AfterThrowing(P)  public void threw()         { System.out.println("    @AfterThrowing"); }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean Every every() { return new Every(); } }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("  a normal call:");
            System.out.println("    caller got: " + b.price("Ravi"));
            System.out.println("  a call that throws:");
            try { b.price("nobody"); }
            catch (IllegalArgumentException e) { System.out.println("    caller got: " + e.getClass().getSimpleName() + ": " + e.getMessage()); }
        }
    }
}
