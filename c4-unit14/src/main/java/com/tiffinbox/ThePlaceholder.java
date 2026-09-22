package com.tiffinbox;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.context.support.PropertySourcesPlaceholderConfigurer;

/**
 * THE BREAK, and there are two silent failures here, not one.
 *
 * <p>One typo: the file says {@code tiffinbox.meal}, the placeholder says {@code tiffinbox.mael}.
 * Three ways of writing the same mistake, and only the third one tells you:
 *
 * <ul>
 *   <li>{@code withDefault} — a default after the colon. Context starts, exit 0, nothing logged,
 *       the kitchen runs on the default for ever.
 *   <li>{@code noConfigurer} — no default, and no PropertySourcesPlaceholderConfigurer in the
 *       context. Context starts, exit 0, and the String bean holds the LITERAL TEXT
 *       {@code ${tiffinbox.mael}}. This is the one nobody warns you about: deleting the default
 *       did not make the failure loud, it made it a different silent failure.
 *   <li>{@code configured} — no default, and a PropertySourcesPlaceholderConfigurer registered.
 *       PlaceholderResolutionException, exit 1, and it NAMES THE KEY.
 * </ul>
 *
 * <p>THE CONFIGURER MUST BE {@code static}, and unit 11 is why. It is a BeanFactoryPostProcessor —
 * the hook that runs before any of your beans exist — so the container has to create it without
 * building the configuration class that declares it. A non-static @Bean method would force that
 * class to be built too early, and Spring logs about it rather than failing.
 *
 * <p>Usage: {@code ThePlaceholder withDefault|noConfigurer|configured}
 */
public final class ThePlaceholder {

    private ThePlaceholder() { }

    @Configuration
    @PropertySource("classpath:kitchen.properties")
    static class WithDefault {
        @Bean String meal(@Value("${tiffinbox.mael:VEG}") String meal) { return meal; }
    }

    @Configuration
    @PropertySource("classpath:kitchen.properties")
    static class NoConfigurer {
        @Bean String meal(@Value("${tiffinbox.mael}") String meal) { return meal; }
    }

    @Configuration
    @PropertySource("classpath:kitchen.properties")
    static class Configured {
        /** static — see the class comment, and unit 11. */
        @Bean static PropertySourcesPlaceholderConfigurer placeholders() {
            return new PropertySourcesPlaceholderConfigurer();
        }
        @Bean String meal(@Value("${tiffinbox.mael}") String meal) { return meal; }
    }

    public static void main(String[] args) {
        Class<?> cfg;
        String shown;
        switch (args.length == 1 ? args[0] : "") {
            case "withDefault"  -> { cfg = WithDefault.class;  shown = "${tiffinbox.mael:VEG}   no configurer"; }
            case "noConfigurer" -> { cfg = NoConfigurer.class; shown = "${tiffinbox.mael}       no configurer"; }
            case "configured"   -> { cfg = Configured.class;   shown = "${tiffinbox.mael}       PropertySourcesPlaceholderConfigurer registered"; }
            default -> {
                System.err.println("ThePlaceholder: usage: ThePlaceholder "
                        + "withDefault|noConfigurer|configured");
                System.exit(2);
                return;
            }
        }
        System.out.println("placeholder: " + shown);
        System.out.println("the file spells it tiffinbox.meal");
        try (AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(cfg)) {
            System.out.println("STARTED. the bean holds: [" + ctx.getBean(String.class) + "]");
            System.out.println("meanwhile tiffinbox.meal="
                    + ctx.getEnvironment().getProperty("tiffinbox.meal") + " and nothing read it.");
        }
    }
}
