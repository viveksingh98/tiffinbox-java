package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** The thing that needs exactly one rail. Do not change this file. */
public final class Desk {

    private final Rail rail;

    public Desk(Rail rail) { this.rail = rail; }

    @Configuration
    static class Wiring {
        @Bean Desk desk(Rail rail) { return new Desk(rail); }
    }

    public static void main(String[] args) {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        if (args.length > 0 && !args[0].isEmpty()) {
            ctx.getEnvironment().setActiveProfiles(args[0].split(","));
        }
        ctx.register(TiffinBoxConfig.class, Wiring.class);
        ctx.refresh();
        try (ctx) {
            System.out.println("STARTED. the desk got: " + ctx.getBean(Desk.class).rail.describe());
        }
    }
}
