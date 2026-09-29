package com.tiffinbox.harness;

import org.springframework.boot.context.properties.bind.Bindable;
import org.springframework.boot.context.properties.bind.Binder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;

import java.util.Arrays;

/**
 * What does a YAML list become? {@code ListKey <key> <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}), prints the keys the list's lines became in each file Boot loaded (as
 * {@link Keys} does), then asks for it three ways: the Environment, by the list's own name; the Environment, by one
 * item's name; and Boot's {@code Binder} - the tool Boot builds typed objects with - for a {@code List<String>}.
 */
public final class ListKey {

    public static void main(String[] args) throws Exception {
        String key = args[0];
        ConfigurableApplicationContext ctx = Run.tiffinbox(Arrays.copyOfRange(args, 1, args.length), null);
        try {
            ConfigurableEnvironment env = ctx.getEnvironment();
            for (String line : Keys.listing(env, new String[] {key})) {
                System.out.println(line);
            }
            System.out.println("env.getProperty(\"" + key + "\")    = " + env.getProperty(key));
            System.out.println("env.getProperty(\"" + key + "[1]\") = " + env.getProperty(key + "[1]"));
            System.out.println("Boot's Binder, asked for a List<String> at " + key + ": "
                    + Binder.get(env).bind(key, Bindable.listOf(String.class)).orElse(null));
        } finally {
            ctx.close();
        }
    }
}
