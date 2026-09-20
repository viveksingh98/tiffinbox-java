package com.tiffinbox;

import java.util.ArrayList;
import java.util.List;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The break, and it is four breaks in one JVM so the four answers are comparable.
 *
 * <p>One callback throws. The question is which of the REMAINING callbacks still run — for
 * this bean, and for the beans that were already finished. The answer decides where it is
 * safe to put work that acquires something.
 */
public final class ThrowInACallback {

    /** Where this run throws. */
    static String throwAt = "";

    /** What actually ran, this run. */
    static final List<String> RAN = new ArrayList<>();

    private ThrowInACallback() { }

    static void mark(String what) {
        RAN.add(what);
        if (what.equals(throwAt)) {
            throw new IllegalStateException("the gas is off — " + what + " cannot finish");
        }
    }

    /** A bean built BEFORE the stove, so we can see whether a finished bean is cleaned up. */
    public static class Pantry {
        @jakarta.annotation.PostConstruct void stock() { mark("pantry @PostConstruct"); }
        @jakarta.annotation.PreDestroy void empty() { mark("pantry @PreDestroy"); }
    }

    /** The bean that fails. */
    public static class Stove {
        public Stove(Pantry p) { mark("stove constructor"); }
        @jakarta.annotation.PostConstruct void ignite() { mark("stove @PostConstruct"); }
        void warmUp() { mark("stove initMethod"); }
        @jakarta.annotation.PreDestroy void cool() { mark("stove @PreDestroy"); }
        void lockUp() { mark("stove destroyMethod"); }
    }

    @Configuration
    public static class Config {
        @Bean Pantry pantry() { return new Pantry(); }
        @Bean(initMethod = "warmUp", destroyMethod = "lockUp")
        Stove stove(Pantry p) { return new Stove(p); }
    }

    public static void main(String[] args) {
        String[] cases = {"", "stove constructor", "stove @PostConstruct", "stove initMethod"};
        System.out.println("one callback throws; every other line of every case is identical");
        for (String c : cases) {
            throwAt = c;
            RAN.clear();
            String verdict;
            String first = "-";
            try (AnnotationConfigApplicationContext ctx =
                         new AnnotationConfigApplicationContext(Config.class)) {
                verdict = "started, then closed normally";
            } catch (RuntimeException e) {
                verdict = e.getClass().getName();
                first = e.getMessage() == null ? "(none)" : e.getMessage().split("\n")[0];
            }
            System.out.println();
            System.out.printf("[%s]%n", c.isEmpty() ? "nothing throws" : c);
            System.out.printf("  verdict   %s%n", verdict);
            System.out.printf("  first line   %s%n", first);
            System.out.printf("  ran (%d)   %s%n", RAN.size(), String.join(" · ", RAN));
            boolean stoveDestroyed = RAN.contains("stove @PreDestroy");
            boolean pantryDestroyed = RAN.contains("pantry @PreDestroy");
            System.out.printf("  the bean that failed was cleaned up   %s%n",
                    c.isEmpty() ? "n/a" : String.valueOf(stoveDestroyed));
            System.out.printf("  the bean that had FINISHED was cleaned up   %s%n", pantryDestroyed);
        }
    }
}
