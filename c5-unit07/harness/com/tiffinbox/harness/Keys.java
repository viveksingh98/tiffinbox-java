package com.tiffinbox.harness;

import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.OriginLookup;
import org.springframework.boot.origin.TextResourceOrigin;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.EnumerablePropertySource;
import org.springframework.core.env.PropertySource;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

/**
 * What did Boot read out of each file, line by line? {@code Keys <key or -> <prefix,prefix,...> <TiffinBox's arguments>}.
 *
 * <p>Runs TiffinBox's own main (see {@link Run}). Then, for every file Boot loaded - each one is a property source whose
 * name starts "Config resource", and a YAML file with two documents is two of them - it prints the keys that start
 * with one of the prefixes, each beside the line of the file it came from, exactly as written, and the value Boot holds
 * for it with that value's Java type. When a key is given (not "-"), it ends with what the Environment answers for that
 * key and the bean field it ends up in.
 */
public final class Keys {

    public static void main(String[] args) throws Exception {
        String key = args[0];
        String[] prefixes = args[1].split(",");
        ConfigurableApplicationContext ctx = Run.tiffinbox(Arrays.copyOfRange(args, 2, args.length), null);
        try {
            for (String line : listing(ctx.getEnvironment(), prefixes)) {
                System.out.println(line);
            }
            if (!key.equals("-")) {
                System.out.println("KEY " + key + " -> WINNER " + ctx.getEnvironment().getProperty(key) + " · " + Run.field(ctx, key));
            }
            System.out.println(Run.classPathLine());
        } finally {
            ctx.close();
        }
    }

    static List<String> listing(ConfigurableEnvironment env, String[] prefixes) throws Exception {
        List<PropertySource<?>> sources = new ArrayList<>();
        env.getPropertySources().forEach(sources::add);
        List<String> out = new ArrayList<>();
        for (int i = 0; i < sources.size(); i++) {
            PropertySource<?> ps = sources.get(i);
            if (!ps.getName().startsWith("Config resource")) {
                continue;
            }
            out.add("source " + (i + 1) + " of " + sources.size() + " · " + ps.getName());
            List<Object[]> rows = new ArrayList<>();          // {line (1-based), the line as written, key, value}
            for (String n : ((EnumerablePropertySource<?>) ps).getPropertyNames()) {
                if (!matches(n, prefixes)) {
                    continue;
                }
                @SuppressWarnings("unchecked")
                Origin o = ((OriginLookup<String>) ps).getOrigin(n);
                TextResourceOrigin t = (TextResourceOrigin) o;
                rows.add(new Object[] {t.getLocation().getLine() + 1, Run.line(t), n, ps.getProperty(n)});
            }
            if (rows.isEmpty()) {
                out.add("  (no key under " + String.join(", ", prefixes) + ")");
                continue;
            }
            rows.sort(Comparator.comparingInt(r -> (Integer) r[0]));
            int width = rows.stream().mapToInt(r -> ((String) r[1]).length()).max().orElse(0);
            for (Object[] r : rows) {
                Object v = r[3];
                out.add(String.format("  line %2d | %-" + width + "s  ->  %s = %s (%s)", r[0], r[1], r[2], v,
                        v == null ? "null" : v.getClass().getSimpleName()));
            }
        }
        return out;
    }

    static boolean matches(String name, String[] prefixes) {
        for (String p : prefixes) {
            if (name.equals(p) || name.startsWith(p + ".") || name.startsWith(p + "[")) {
                return true;
            }
        }
        return false;
    }
}
