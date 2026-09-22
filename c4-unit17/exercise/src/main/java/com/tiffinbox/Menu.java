package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.io.Resource;

/**
 * Reads the menu. Works when you run it from your editor. Run it the way it ships and see.
 */
public class Menu {
    public static void main(String[] args) throws Exception {
        try (var ctx = new AnnotationConfigApplicationContext()) {
            ctx.refresh();
            Resource r = ctx.getResource("classpath:com/tiffinbox/menu.csv");
            System.out.println("exists() : " + r.exists());
            System.out.println(new String(r.getInputStream().readAllBytes()).strip());
        }
    }
}
