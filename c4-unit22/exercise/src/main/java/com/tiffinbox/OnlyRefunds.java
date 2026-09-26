package com.tiffinbox;

import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * Only refunds must be audited. This rule audits too much. Fix the pointcut so that ONLY refund()
 * runs the advice - and prove it the unit's way: the control bean 'menu' must come back as its
 * plain class, not a proxy.
 */
public class OnlyRefunds {
    static int audited;
    @Aspect public static class Audit {
        @Before("execution(* com.tiffinbox.*.*(..))")          // TODO: too wide
        public void a() { audited++; }
    }
    @Configuration @EnableAspectJAutoProxy
    static class Cfg { @Bean Billing billing() { return new BillingService(); } @Bean Menu menu() { return new MenuService(); } @Bean Audit audit() { return new Audit(); } }
    public static void main(String[] x) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class); Menu m = ctx.getBean(Menu.class);
            b.price("Ravi"); b.refund("Ravi"); m.dishes();
            System.out.println("audited calls: " + audited + "   (want 1)");
            System.out.println("menu bean    : " + m.getClass().getName());
        }
    }
}
