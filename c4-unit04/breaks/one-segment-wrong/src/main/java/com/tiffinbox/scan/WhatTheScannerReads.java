package com.tiffinbox.scan;

import java.lang.annotation.Annotation;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.stereotype.Component;

/**
 * How the container finds your classes without you listing them — and what it is actually
 * reading while it does.
 *
 * <p>The static initialisers in the scanned classes are the instrument: a line prints the
 * first time the JVM LOADS that class. Watch which lines appear, and when.
 */
public final class WhatTheScannerReads {

    private WhatTheScannerReads() { }

    public static void main(String[] args) {
        System.out.println("STEREOTYPES - four words, one mechanism (derived by reflection, not asserted)");
        for (Class<?> a : List.of(org.springframework.stereotype.Component.class,
                org.springframework.stereotype.Service.class,
                org.springframework.stereotype.Repository.class,
                org.springframework.stereotype.Controller.class)) {
            List<String> meta = new ArrayList<>();
            for (Annotation ann : a.getAnnotations()) {
                if (ann.annotationType() == Component.class) {
                    meta.add("@Component");
                }
            }
            System.out.printf("  @%-12s meta-annotated with %s%n", a.getSimpleName(),
                    a == Component.class ? "(it IS @Component)" : meta);
        }

        System.out.println("REFRESH - and the only classes the JVM loads are the ones it instantiates");
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(ScanConfig.class)) {
            String[] all = ctx.getBeanDefinitionNames().clone();
            Arrays.sort(all);
            List<String> mine = new ArrayList<>();
            for (String n : all) {
                if (!n.startsWith("org.springframework.")) {
                    mine.add(n);
                }
            }
            if (mine.isEmpty()) {
                throw new IllegalStateException("the scan registered nothing; a zero here is not a measurement");
            }
            System.out.println("REGISTERED (sorted, ours only)");
            for (String n : mine) {
                System.out.println("    " + n);
            }
            System.out.println("  registered: " + mine.size()
                    + "   classes in those packages wearing a stereotype: 4"
                    + "   excluded by the filter: 1");
            System.out.println("NOW ask for the lazy one, and watch the load happen");
            System.out.println("  report(): " + ctx.getBean(com.tiffinbox.kitchen.ReportBuilder.class).report());
            System.out.println("  dishes(): " + ctx.getBean(com.tiffinbox.kitchen.BillingService.class).dishes());
        }
    }
}
