package com.tiffinbox.harness;

import org.springframework.boot.context.properties.source.ConfigurationProperty;
import org.springframework.boot.context.properties.source.ConfigurationPropertySources;
import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.OriginLookup;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Who answers a key? {@code Winner <key> <the arguments TiffinBox's main gets>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}), then walks the live Environment's property sources IN ORDER and prints
 * what each one holds for the key under that exact name, with Boot's {@code Origin} where the source tracks one. The
 * WINNER is what the Environment answers. "From source N" is the source Boot's view at the top of the stack found it in,
 * asked the way the view asks - so when the view found it under another spelling (an environment variable written
 * differently, a camelCase key in a file), the line says so, with the spelling it found. Then the bean field the key ends
 * up in, and which file the class path gives for Boot's two file names. Then it closes the context, which stops
 * TiffinBox's server.
 */
public final class Winner {

    public static void main(String[] args) throws Exception {
        String key = args[0];
        ConfigurableApplicationContext ctx = Run.tiffinbox(Arrays.copyOfRange(args, 1, args.length), null);
        try {
            for (String line : report(ctx, key)) {
                System.out.println(line);
            }
        } finally {
            ctx.close();
        }
    }

    static List<String> report(ConfigurableApplicationContext context, String key) throws Exception {
        ConfigurableEnvironment env = context.getEnvironment();
        List<PropertySource<?>> sources = new ArrayList<>();
        env.getPropertySources().forEach(sources::add);
        ConfigurationProperty found = Run.viewFinds(env, key);
        PropertySource<?> answering = found == null ? null : (PropertySource<?>) found.getSource().getUnderlyingSource();
        int from = answering == null ? 0 : sources.indexOf(answering) + 1;
        List<String> out = new ArrayList<>();
        out.add("KEY " + key + " -> WINNER " + env.getProperty(key) + " · from source " + from + " of " + sources.size() + ", "
                + (answering == null ? "(none)" : answering.getName()));
        if (answering != null && answering.getProperty(key) == null) {
            out.add("  not under that name: Boot's view found it " + Run.describe(found.getOrigin()));
        }
        for (int i = 0; i < sources.size(); i++) {
            PropertySource<?> ps = sources.get(i);
            boolean view = ConfigurationPropertySources.isAttachedConfigurationPropertySource(ps);
            Object v = ps.getProperty(key);
            String origin = "";
            if (v != null && !view && ps instanceof OriginLookup<?> lookup) {
                @SuppressWarnings("unchecked")
                Origin o = ((OriginLookup<String>) lookup).getOrigin(key);
                origin = o == null ? "" : "   origin: " + o;
            }
            out.add(String.format("  %2d %-26s %s%s%s", i + 1, ps.getName(), v == null ? "-" : v,
                    view ? "   (Boot's view over the sources below it)" : "", origin));
        }
        out.add(Run.field(context, key));
        out.add(Run.classPathLine());
        return out;
    }
}
