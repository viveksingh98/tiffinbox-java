package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * A / B / A′ on @Order, in one JVM, one session — and the unit stands on the row that does NOT
 * move. @Order sorts a list the container hands you. It does not decide the order the
 * container builds things in, and most of the internet says otherwise.
 */
public final class WhatOrderOrders {

    private WhatOrderOrders() { }

    public static void main(String[] args) {
        run("[A ] no @Order anywhere        ", Checks.NoOrder.class);
        run("[B ] @Order(3) @Order(1) @Order(2), methods NOT moved", Checks.Ordered.class);
        run("[A'] no @Order anywhere, again ", Checks.NoOrder.class);
    }

    static void run(String tag, Class<?> config) {
        StartupCheck.BUILT.clear();
        System.out.println();
        System.out.println(tag);
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(config)) {
            System.out.printf("  order the container BUILT them   %s%n", StartupCheck.BUILT);
            System.out.printf("  order in the injected List       %s%n",
                    ctx.getBean(Checks.OpeningRoutine.class).runAll());
            System.out.printf("  order getBeanNamesForType gives  %s%n",
                    java.util.Arrays.toString(ctx.getBeanNamesForType(StartupCheck.class)));
            System.out.printf("  @Order values on the definitions %s%n", orderValues(ctx));
        }
    }

    /**
     * DERIVED off the definition's own factory method — which is where the annotation is —
     * and it is the nothing-else-was-touched evidence: the same three beans in both columns.
     */
    static String orderValues(AnnotationConfigApplicationContext ctx) {
        StringBuilder sb = new StringBuilder();
        for (String n : ctx.getBeanNamesForType(StartupCheck.class)) {
            org.springframework.beans.factory.support.RootBeanDefinition bd =
                    (org.springframework.beans.factory.support.RootBeanDefinition)
                            ctx.getBeanFactory().getMergedBeanDefinition(n);
            java.lang.reflect.Method fm = bd.getResolvedFactoryMethod();
            org.springframework.core.annotation.Order o =
                    (fm == null ? null : fm.getAnnotation(
                            org.springframework.core.annotation.Order.class));
            sb.append(n).append('=').append(o == null ? "none" : o.value()).append("  ");
        }
        return sb.toString().trim();
    }
}
