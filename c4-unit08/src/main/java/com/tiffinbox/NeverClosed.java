package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The break. The context is created and never closed — which is what every `main` that ends
 * with a blank line does. The JVM exits 0, nothing is logged, and the callback you wrote to
 * release something never runs.
 *
 * <p>Run it twice: {@code NeverClosed} and {@code NeverClosed --hook}. The only difference is
 * one line.
 */
public final class NeverClosed {

    private NeverClosed() { }

    public static class Freezer implements AutoCloseable {
        @jakarta.annotation.PostConstruct void plugIn() {
            System.out.println("  @PostConstruct  the freezer is on");
        }
        @jakarta.annotation.PreDestroy void defrost() {
            System.out.println("  @PreDestroy     the freezer was emptied");
        }
        @Override public void close() {
            System.out.println("  close()         the door is shut");
        }
    }

    @Configuration
    public static class Config {
        @Bean Freezer freezer() { return new Freezer(); }
    }

    public static void main(String[] args) {
        boolean hook = args.length > 0 && args[0].equals("--hook");
        System.out.println(hook
                ? "[with registerShutdownHook()]" : "[no close(), no shutdown hook]");
        AnnotationConfigApplicationContext ctx =
                new AnnotationConfigApplicationContext(Config.class);
        if (hook) {
            ctx.registerShutdownHook();
        }
        System.out.println("  the application did its work and main() is about to return");
    }
}
