package com.tiffinbox;

import org.aspectj.lang.annotation.*;
import org.springframework.context.annotation.*;

/**
 * Solution. @annotation selects exactly the method carrying @Audited - and when the proxy is built it can
 * already rule out every method without @Audited, so the menu bean stays plain.
 * runs the advice - and prove it the unit's way: the control bean 'menu' must come back as its
 * plain class, not a proxy.
 */
public class OnlyRefunds {
    static int audited;
    @Aspect public static class Audit {
        @Before("@annotation(com.tiffinbox.Audited)")               // exactly the marked method
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
