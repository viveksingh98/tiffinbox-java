package com.tiffinbox;

import java.util.Arrays;
import java.util.List;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

/**
 * What @EnableAspectJAutoProxy actually adds to the context: the report diff.
 * Same two beans in both configurations; one annotation of difference.
 */
public final class WhatItSwitchesOn {

    private WhatItSwitchesOn() { }

    @Configuration
    static class Without {
        @Bean Billing billing() { return new BillingService(); }
        @Bean AuditAspect auditAspect() { return new AuditAspect(); }
    }

    @Configuration
    @EnableAspectJAutoProxy
    static class With {
        @Bean Billing billing() { return new BillingService(); }
        @Bean AuditAspect auditAspect() { return new AuditAspect(); }
    }

    /**
     * Sorted bean names, MINUS the configuration class's own bean. That bean is named after the
     * class (whatItSwitchesOn.Without / .With), so it differs between the two runs for a reason
     * that has nothing to do with the annotation - and the first version of this diff reported it
     * as "added" and "removed". The die guard below caught that. Its name is asked of the context,
     * not typed.
     */
    static List<String> names(Class<?> cfg) {
        try (var ctx = new AnnotationConfigApplicationContext(cfg)) {
            List<String> self = Arrays.asList(ctx.getBeanNamesForType(cfg));
            return Arrays.stream(ctx.getBeanDefinitionNames()).filter(n -> !self.contains(n))
                         .sorted().toList();
        }
    }

    public static void main(String[] args) {
        List<String> a = names(Without.class), b = names(With.class);
        System.out.println("bean definitions WITHOUT the annotation : " + a.size());
        System.out.println("bean definitions WITH it                : " + b.size());
        System.out.println("added by one annotation:");
        b.stream().filter(x -> !a.contains(x)).forEach(x -> System.out.println("  + " + x));
        long removed = a.stream().filter(x -> !b.contains(x)).count();
        System.out.println("removed: " + removed);
        if (b.size() - a.size() != b.stream().filter(x -> !a.contains(x)).count()) {
            System.err.println("WhatItSwitchesOn: the diff does not add up - this capture is not evidence.");
            System.exit(2);
        }
    }
}
