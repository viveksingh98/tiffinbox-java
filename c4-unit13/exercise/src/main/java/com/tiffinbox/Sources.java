package com.tiffinbox;

import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;

/**
 * The ordered stack, printed OFF THE LIVE Environment.
 *
 * <p>Nothing here is drawn by hand. The list is the iteration order of
 * ConfigurableEnvironment.getPropertySources(), the count is that iteration's length, and the
 * winner is what getProperty actually returned — so the slide is made FROM this output rather
 * than beside it.
 *
 * <p>ONE KEY IS PLANTED IN EVERY SOURCE THIS PROGRAM CAN REACH. That is what makes the winner a
 * fact instead of a diagram: if precedence were the other way round, this same program would
 * print a different last line without anybody editing it.
 *
 * <p>Usage: {@code Sources [--key=NAME] [sysprop]}
 *
 * <p>The key defaults to {@code tiffinbox.rail}, which is the one the video contests. It is a
 * parameter because the exercise contests a DIFFERENT key, and a program that can only ever ask
 * about one hard-coded name would have made the exercise's own solution unverifiable.
 *
 * <p>With no argument, no JVM system property is set, and the file sources are the only
 * contenders — which is the capture where swapping the two @PropertySource lines MOVES THE
 * ANSWER. With {@code sysprop}, one system property is set before refresh, and it wins; that is
 * a SECOND, SEPARATE capture, because a capture in which the answer never changes teaches
 * nothing about the flip that is going on underneath it. Both are shipped, and the README hashes
 * them apart.
 */
public final class Sources {

    /** The key the video contests, and the default. One name, so no reader has to track three. */
    static final String DEFAULT_KEY = "tiffinbox.rail";

    private Sources() { }

    public static void main(String[] args) {
        String key = DEFAULT_KEY;
        boolean sysprop = false;
        for (String a : args) {
            if (a.startsWith("--key=")) {
                key = a.substring("--key=".length());
            } else if (a.equals("sysprop")) {
                sysprop = true;
            } else {
                die("unknown argument " + a + " -- usage: Sources [--key=NAME] [sysprop]");
            }
        }
        if (key.isEmpty()) {
            die("--key= with no name. Asking which source wins for the empty string is not a question.");
        }
        final String KEY = key;
        if (sysprop) {
            System.setProperty(KEY, "FROM-JVM-SYSTEM-PROPERTY");
        }
        try (AnnotationConfigApplicationContext ctx =
                     new AnnotationConfigApplicationContext(TiffinBoxConfig.class)) {

            ConfigurableEnvironment env = ctx.getEnvironment();
            System.out.println("property sources, in the order the Environment holds them:");
            int i = 0;
            int carrying = 0;
            for (PropertySource<?> ps : env.getPropertySources()) {
                Object v = ps.containsProperty(KEY) ? ps.getProperty(KEY) : null;
                if (v != null) {
                    carrying++;
                }
                System.out.printf("  %d. %-30s %s%n", ++i, ps.getName(),
                        v == null ? "(no " + KEY + ")" : KEY + "=" + v);
            }
            // DERIVED, both of them: the length of the iteration, and how many of those sources
            // actually carried the key. A hand-typed 4 here would be the first thing to rot.
            System.out.println("sources=" + i);
            System.out.println("sources carrying " + KEY + "=" + carrying);

            if (i < 2) {
                die("only " + i + " property source(s). There is no precedence to show with one "
                        + "source, so this capture cannot be evidence of anything.");
            }
            if (carrying < 2) {
                die("only " + carrying + " source(s) carry " + KEY + ". The whole point of this "
                        + "program is a contested key; with one claimant the winner is not a "
                        + "measurement, it is the only answer available.");
            }
            System.out.println("WINNER  env.getProperty(" + KEY + ") = " + env.getProperty(KEY));
        }
    }

    static void die(String why) {
        System.out.flush();
        System.err.println("Sources: " + why);
        System.exit(2);
    }
}
