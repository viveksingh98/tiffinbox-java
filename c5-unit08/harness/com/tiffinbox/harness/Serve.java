package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;

/**
 * TiffinBox, serving. {@code Serve <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}), prints the record (or that the tree has none) and which file the class
 * path gave, then returns WITHOUT closing the context: TiffinBox keeps serving, exactly as its own main leaves it, until
 * POST /shutdown stops its server and the JVM exits. It runs on the previous tree too, so it never names the record's
 * class in its code.
 */
public final class Serve {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        System.out.println(Run.recordLine(ctx));
        System.out.println(Run.classPathLine());
    }
}
