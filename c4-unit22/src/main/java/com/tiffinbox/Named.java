package com.tiffinbox;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * A NAMED pointcut: the expression lives in exactly one place, and two pieces of advice refer to it
 * by name. Change the rule once and both follow - which is the fix for a wildcard copied into five
 * annotations and edited in four.
 */
public final class Named {

    private Named() { }

    @Aspect public static class Audit {
        @Pointcut("execution(* com.tiffinbox.Billing.*(..)) && @annotation(com.tiffinbox.Audited)")
        void auditedBilling() { }                                  // the rule, named, written once

        @Before("auditedBilling()")
        public void in(JoinPoint jp)  { System.out.println("  [audit] about to run " + jp.getSignature().getName()); }

        @AfterReturning(pointcut = "auditedBilling()", returning = "r")
        public void out(Object r)     { System.out.println("  [audit] it returned " + r); }
    }

    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean Audit audit() { return new Audit(); } }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("price  -> " + b.price("Ravi"));
            System.out.println("refund -> " + b.refund("Ravi"));
        }
    }
}
