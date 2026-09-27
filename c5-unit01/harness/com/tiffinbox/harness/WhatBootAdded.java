package com.tiffinbox.harness;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

/**
 * Unit 01's receipt for "same beans": start TiffinBox the way Course 4 left it (a context you build yourself) or the
 * way Boot does (SpringApplication.run), and ask each what it holds. One way per JVM - receipts.sh runs both.
 * TiffinBoxApp is named only as a string, so this file compiles against either project.
 */
public final class WhatBootAdded {
    private WhatBootAdded() { }

    public static void main(String[] args) throws Exception {
        String way = args[0];
        System.setProperty("tiffinbox.port", args[1]);
        Class<?> app = Class.forName("com.tiffinbox.web.TiffinBoxApp");
        ConfigurableApplicationContext ctx = way.equals("boot")
                ? SpringApplication.run(app, Arrays.copyOfRange(args, 1, args.length))
                : new AnnotationConfigApplicationContext(app);
        try (ctx) {
            var bf = ctx.getBeanFactory();
            List<String> yours = new ArrayList<>();
            int auto = 0, spring = 0;
            for (String n : ctx.getBeanDefinitionNames()) {
                Class<?> t = bf.getType(n);
                String c = t == null ? "" : t.getName();
                if (c.startsWith("com.tiffinbox")) yours.add(n);
                else if (c.contains("AutoConfiguration")) auto++;
                else spring++;
            }
            yours.sort(null);
            List<String> sources = new ArrayList<>();
            ctx.getEnvironment().getPropertySources().forEach(s -> sources.add(s.getName()));
            System.out.println(way.equals("boot") ? "SpringApplication.run(TiffinBoxApp.class, args):"
                                                  : "new AnnotationConfigApplicationContext(TiffinBoxApp.class):");
            System.out.println("  your definitions (" + yours.size() + "): " + yours);
            System.out.println("  auto-configuration definitions: " + auto);
            System.out.println("  Spring's own definitions: " + spring);
            System.out.println("  property sources, in the order they are asked: " + sources);
        }
    }
}
