package com.tiffinbox.harness;

import com.sun.net.httpserver.HttpServer;
import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringApplicationRunListener;
import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.OriginLookup;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;

import java.lang.reflect.Field;
import java.net.InetSocketAddress;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Who answers a key? {@code Winner <key> <the arguments TiffinBox's main gets>}.
 *
 * <p>It runs TiffinBox's OWN main, unchanged - {@code TiffinBoxServer.main(args)}, the tree's code, bridge or no bridge -
 * and catches the context that main starts through Boot's {@code SpringApplication.withHook}: a run listener that is
 * handed the context when it is ready. Then it walks the live Environment's property sources IN ORDER and prints what
 * each one holds for the key, the first one that holds it, the bean field the key ends up in, and the arguments Boot
 * kept as non-option arguments. Then it closes the context, which stops TiffinBox's server.
 *
 * <p>No annotations: TiffinBox's {@code @ComponentScan("com.tiffinbox")} registers annotated classes only, so it never
 * sees this one.
 */
public final class Winner {

    private static volatile ConfigurableApplicationContext ctx;

    public static void main(String[] args) throws Exception {
        String key = args[0];
        String[] tiffinboxArgs = Arrays.copyOfRange(args, 1, args.length);
        SpringApplication.withHook(app -> new SpringApplicationRunListener() {
            @Override
            public void ready(ConfigurableApplicationContext context, Duration timeTaken) {
                ctx = context;
            }
        }, () -> TiffinBoxServer.main(tiffinboxArgs));
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
        List<String> rows = new ArrayList<>();
        int first = 0;
        for (int i = 0; i < sources.size(); i++) {
            PropertySource<?> ps = sources.get(i);
            Object v = ps.getProperty(key);
            boolean view = isView(ps);
            if (first == 0 && !view && v != null) {
                first = i + 1;
            }
            String origin = "";
            if (v != null && !view && ps instanceof OriginLookup<?> lookup) {
                @SuppressWarnings("unchecked")
                Origin o = ((OriginLookup<String>) lookup).getOrigin(key);
                origin = o == null ? "" : "   origin: " + o;
            }
            rows.add(String.format("  %2d %-26s %s%s%s", i + 1, ps.getName(), v == null ? "-" : v,
                    view ? "   (Boot's view over the sources below it)" : "", origin));
        }
        List<String> out = new ArrayList<>();
        String winner = env.getProperty(key);
        out.add("KEY " + key + " -> WINNER " + winner + " · from source " + first + " of " + sources.size() + ", "
                + (first == 0 ? "(none)" : sources.get(first - 1).getName()));
        out.addAll(rows);
        out.add(field(context, key));
        out.add("non-option arguments Boot kept: " + context.getBean(ApplicationArguments.class).getNonOptionArgs());
        return out;
    }

    /** Boot's ConfigurationPropertySourcesPropertySource: it answers from the sources below it, it holds nothing itself. */
    static boolean isView(PropertySource<?> ps) {
        return ps.getName().equals("configurationProperties");
    }

    /** The bean field each of TiffinBox's four keys ends up in, read off the live bean. */
    static String field(ConfigurableApplicationContext context, String key) throws Exception {
        return switch (key) {
            case "tiffinbox.cooks" -> "the bean's own field: OrderQueue.cooks = " + read(context, "com.tiffinbox.OrderQueue", "cooks");
            case "tiffinbox.days" -> "the bean's own field: TiffinBoxServer.days = " + read(context, "com.tiffinbox.web.TiffinBoxServer", "days");
            case "tiffinbox.jdbc-url" -> "the bean's own field: Database.url = " + read(context, "com.tiffinbox.Database", "url");
            case "tiffinbox.port" -> {
                HttpServer server = (HttpServer) read(context, "com.tiffinbox.web.TiffinBoxServer", "server");
                InetSocketAddress a = server.getAddress();
                yield "the bean's own field: TiffinBoxServer.port = " + read(context, "com.tiffinbox.web.TiffinBoxServer", "port")
                        + " · its server's socket: " + a.getAddress().getHostAddress() + ":" + a.getPort();
            }
            default -> "the bean's own field: (no TiffinBox bean reads " + key + ")";
        };
    }

    static Object read(ConfigurableApplicationContext context, String type, String name) throws Exception {
        Class<?> c = Class.forName(type);
        Field f = c.getDeclaredField(name);
        f.setAccessible(true);
        return f.get(context.getBean(c));
    }
}
