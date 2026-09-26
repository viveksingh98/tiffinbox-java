package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

/** The four words, printed by the join point they describe. Proxy numbers masked by the program. */
public final class FourWords {

    private FourWords() { }

    @Configuration
    @EnableAspectJAutoProxy
    static class Cfg {
        @Bean Billing billing() { return new BillingService(); }
        @Bean AuditAspect auditAspect() { return new AuditAspect(); }
    }

    public static void main(String[] args) {
        try (var ctx = new AnnotationConfigApplicationContext(Cfg.class)) {
            Billing b = ctx.getBean(Billing.class);
            System.out.println("the bean I got : " + mask(b.getClass().getName()));
            System.out.println("calling price(\"Ravi\"):");
            System.out.println("  -> " + b.price("Ravi"));
        }
    }

    static String mask(String s) {
        return s.replaceAll("\\$Proxy\\d+", "\\$Proxy<n>").replaceAll("\\$\\$SpringCGLIB\\$\\$\\d+", "\\$\\$SpringCGLIB\\$\\$<n>");
    }
}
