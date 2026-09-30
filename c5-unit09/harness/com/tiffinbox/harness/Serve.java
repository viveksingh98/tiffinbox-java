package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;

/**
 * TiffinBox, serving. {@code Serve <TiffinBox's arguments>}.
 *
 * <p>Prints which file the class path gives (before anything starts, so a failed start shows it too), runs TiffinBox's
 * own main (see {@link Run}), prints the record, then returns WITHOUT closing the context: TiffinBox keeps serving,
 * exactly as its own main leaves it, until POST /shutdown stops its server and the JVM exits.
 */
public final class Serve {

    public static void main(String[] args) throws Exception {
        System.out.println(Run.classPathLine());
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        System.out.println(Run.recordLine(ctx));
    }
}
