package com.tiffinbox;

import java.util.List;
import org.springframework.resilience.annotation.*;

/**
 * Where do the resilience annotations come from, and what do they do with nothing set? Read off the classes
 * themselves - their jar, and their defaults - not off a slide.
 */
public final class WhereItLives {
    private WhereItLives() { }
    static String jar(Class<?> c) { return c.getProtectionDomain().getCodeSource().getLocation().getPath().replaceAll(".*/", ""); }
    static Object dflt(Class<?> c, String m) throws Exception { return c.getMethod(m).getDefaultValue(); }
    public static void main(String[] a) throws Exception {
        for (Class<?> c : List.of(Retryable.class, ConcurrencyLimit.class, EnableResilientMethods.class))
            System.out.printf("  %-24s from %s   (package %s)%n", "@" + c.getSimpleName(), jar(c), c.getPackageName());
        long retries = (Long) dflt(Retryable.class, "maxRetries");
        System.out.println("  @Retryable with nothing set, read off the annotation:");
        System.out.println("    maxRetries = " + retries + "   -> " + (retries + 1) + " attempts in all");
        System.out.println("    delay      = " + dflt(Retryable.class, "delay") + " " + dflt(Retryable.class, "timeUnit")
                + ", multiplier = " + dflt(Retryable.class, "multiplier") + ", jitter = " + dflt(Retryable.class, "jitter"));
        System.out.println("  @ConcurrencyLimit when full, read off the annotation: policy = " + dflt(ConcurrencyLimit.class, "policy"));
    }
}
