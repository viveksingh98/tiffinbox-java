package com.tiffinbox.harness;

import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;

import java.util.Arrays;

/**
 * Who answers the token, and where every source ranks. {@code Token <TiffinBox's arguments>}.
 *
 * <p>Prints what the working folder holds, runs TiffinBox's own main (see {@link Run}), then prints the active profiles,
 * the stack for {@code tiffinbox.shutdown-token} - lengths only, never a value - and the length of the token the record
 * holds. Then it closes the context, which stops TiffinBox's server.
 */
public final class Token {

    private static final String KEY = "tiffinbox.shutdown-token";

    public static void main(String[] args) throws Exception {
        System.out.println(Run.folderLine());
        ConfigurableApplicationContext ctx = Run.tiffinbox(args);
        try {
            ConfigurableEnvironment env = ctx.getEnvironment();
            System.out.println("active profiles: " + Arrays.toString(env.getActiveProfiles()));
            for (String line : Run.stack(env, KEY)) {
                System.out.println(line);
            }
            Object record = ctx.getBean(Class.forName("com.tiffinbox.TiffinBoxProperties"));
            Object token = record.getClass().getMethod("shutdownToken").invoke(record);
            System.out.println("the record's token: " + Run.shown(token));
        } finally {
            ctx.close();
        }
    }
}
