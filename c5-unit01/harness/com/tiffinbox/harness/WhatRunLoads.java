package com.tiffinbox.harness;

import java.util.Collection;
import java.util.TreeSet;
import org.springframework.boot.SpringApplication;

/**
 * Unit 01's receipt for "SpringApplication reads a second list": build a SpringApplication for TiffinBoxApp and print
 * the initializers and listeners it holds BEFORE run() - nothing has started yet, so everything here was loaded by
 * the constructor from META-INF/spring.factories. receipts.sh then finds each name in those files.
 */
public final class WhatRunLoads {
    private WhatRunLoads() { }

    public static void main(String[] args) throws Exception {
        var app = new SpringApplication(Class.forName("com.tiffinbox.web.TiffinBoxApp"));
        print("initializers", app.getInitializers());
        print("listeners", app.getListeners());
    }

    private static void print(String what, Collection<?> held) {
        var names = new TreeSet<String>();
        for (Object o : held) names.add(o.getClass().getName());
        System.out.println(what + " (" + names.size() + "): " + String.join(" ", names));
    }
}
