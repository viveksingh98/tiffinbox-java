package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;

/**
 * THE BREAK. Nobody activated a profile, so neither rail exists, and something needs one.
 *
 * <p>Nothing is caught: the exit code is the measurement.
 *
 * <p>{@code fallback} adds the fix, and the fix is a DEFAULT PROFILE rather than a fourth
 * annotation and rather than @Primary. {@code @Profile("default")} means "when nobody chose" —
 * {@code default} is the default profile NAME, which is why the report prints active and default
 * side by side: they are two different things wearing one word.
 *
 * <p>Usage: {@code NobodyChose plain|fallback}
 */
public final class NobodyChose {

    private NobodyChose() { }

    record Desk(Rail rail) {}

    @Configuration
    @PropertySource("classpath:rail.properties")
    static class Plain {
        @Bean @Profile("in-memory") Rail inMemoryRail() { return new InMemoryRail(); }
        @Bean @Profile("jdbc") Rail jdbcRail() { return new JdbcRail("jdbc:h2:mem:tiffinbox"); }
        @Bean Desk desk(Rail rail) { return new Desk(rail); }
    }

    @Configuration
    @PropertySource("classpath:rail.properties")
    static class WithFallback {
        @Bean @Profile("in-memory") Rail inMemoryRail() { return new InMemoryRail(); }
        @Bean @Profile("jdbc") Rail jdbcRail() { return new JdbcRail("jdbc:h2:mem:tiffinbox"); }
        /** The one that exists when nobody chose. Not @Primary — @Primary breaks a TIE, and here
         *  there is no tie, there is nothing. */
        @Bean @Profile("default") Rail fallbackRail() { return new InMemoryRail(); }
        @Bean Desk desk(Rail rail) { return new Desk(rail); }
    }

    public static void main(String[] args) {
        if (args.length != 1 || !(args[0].equals("plain") || args[0].equals("fallback"))) {
            System.err.println("NobodyChose: usage: NobodyChose plain|fallback");
            System.exit(2);
        }
        boolean fallback = args[0].equals("fallback");
        System.out.println("no profile activated" + (fallback ? ", and one bean is @Profile(\"default\")" : ""));
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(
                fallback ? WithFallback.class : Plain.class)) {
            System.out.println("STARTED. the desk got: " + ctx.getBean(Desk.class).rail().describe());
        }
    }
}
