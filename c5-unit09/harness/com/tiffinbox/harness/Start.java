package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;

/**
 * TiffinBox, started and stopped. {@code Start <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}) and prints the record; then it closes the context, which stops
 * TiffinBox's server, and the JVM exits 0. A failed start exits 1, as TiffinBox's own run does. The exercise uses it.
 */
public final class Start {

    public static void main(String[] args) throws Exception {
        ConfigurableApplicationContext ctx = Run.tiffinbox(args, null);
        System.out.println(Run.recordLine(ctx));
        ctx.close();
    }
}
