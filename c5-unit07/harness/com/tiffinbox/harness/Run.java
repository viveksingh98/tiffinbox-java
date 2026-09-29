package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringApplicationRunListener;
import org.springframework.boot.context.properties.source.ConfigurationProperty;
import org.springframework.boot.context.properties.source.ConfigurationPropertyName;
import org.springframework.boot.context.properties.source.ConfigurationPropertySource;
import org.springframework.boot.context.properties.source.ConfigurationPropertySources;
import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.PropertySourceOrigin;
import org.springframework.boot.origin.TextResourceOrigin;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.time.Duration;
import java.util.function.Consumer;

/**
 * What every harness class shares. {@link #tiffinbox} runs TiffinBox's OWN main, unchanged - the tree's
 * {@code TiffinBoxServer.main(args)} - inside Boot's {@code SpringApplication.withHook}, whose run listener is handed the
 * context that main starts.
 *
 * <p>No class in this harness carries a class-level annotation, so TiffinBox's {@code @ComponentScan("com.tiffinbox")},
 * which registers annotated classes only, never picks one up.
 */
final class Run {

    private static volatile ConfigurableApplicationContext ready;

    private Run() {
    }

    /**
     * Runs TiffinBox's main and returns the context once it is ready.
     *
     * @param prepared called when the context exists and before TiffinBox's own configuration is registered, or null
     */
    static ConfigurableApplicationContext tiffinbox(String[] args, Consumer<ConfigurableApplicationContext> prepared) {
        try {
            SpringApplication.withHook(app -> new SpringApplicationRunListener() {
                @Override
                public void contextPrepared(ConfigurableApplicationContext context) {
                    if (prepared != null) {
                        prepared.accept(context);
                    }
                }

                @Override
                public void ready(ConfigurableApplicationContext context, Duration timeTaken) {
                    ready = context;
                }
            }, () -> TiffinBoxServer.main(args));
        } catch (RuntimeException | Error e) {
            // Boot has printed its own report by now, and that report does not always name the type. Name it, then rethrow
            // the same exception: the exit code stays the one TiffinBox's own run gives.
            System.out.println("the exception TiffinBox's main threw: " + e.getClass().getName());
            throw e;
        }
        return ready;
    }

    /**
     * The property Boot's view at the top of the stack finds for a key: it asks the sources below it in order, each
     * through Boot's name mapping, exactly as {@code ConfigurationPropertySourcesPropertySource} does. Null if none has it.
     */
    static ConfigurationProperty viewFinds(ConfigurableEnvironment env, String key) {
        ConfigurationPropertyName name = ConfigurationPropertyName.of(key);
        for (ConfigurationPropertySource source : ConfigurationPropertySources.get(env)) {
            ConfigurationProperty p = source.getConfigurationProperty(name);
            if (p != null) {
                return p;
            }
        }
        return null;
    }

    /**
     * Where a property Boot's view found came from: the name it has in its own source (Boot wraps the origin in a
     * {@code PropertySourceOrigin} that keeps it), the origin, and - when the origin points into a file - that line of the
     * file, as written.
     */
    static String describe(Origin origin) throws IOException {
        String name = null;
        if (origin instanceof PropertySourceOrigin p) {
            name = p.getPropertyName();
            if (p.getOrigin() != null) {
                origin = p.getOrigin();
            }
        }
        String where = (origin instanceof TextResourceOrigin t && t.getLocation() != null)
                ? origin + ", the line reads: " + line(t)
                : String.valueOf(origin);
        return (name == null ? "" : "under the name " + name + " · ") + where;
    }

    /** The line of the file a text origin points at, exactly as written (indentation included). */
    static String line(TextResourceOrigin origin) throws IOException {
        String[] lines = origin.getResource().getContentAsString(StandardCharsets.UTF_8).split("\n", -1);
        int n = origin.getLocation().getLine();          // 0-based; the origin's own toString prints n + 1
        return n < lines.length ? lines[n] : "(past the end of the file)";
    }

    /** Which file the class path gives for a name: jarname!/entry, or a path relative to the working directory. */
    static String classPathFile(String name) throws Exception {
        URL u = Run.class.getClassLoader().getResource(name);
        if (u == null) {
            return "none";
        }
        if ("jar".equals(u.getProtocol())) {
            String s = u.getPath();
            return s.substring(s.lastIndexOf('/', s.indexOf("!/")) + 1);
        }
        return Path.of("").toAbsolutePath().relativize(Path.of(u.toURI())).toString();
    }

    static String classPathLine() throws Exception {
        return "the class path gives: application.yaml <- " + classPathFile("application.yaml")
                + " · application.properties <- " + classPathFile("application.properties");
    }

    /** The bean field each of TiffinBox's four keys ends up in, read off the live bean. */
    static String field(ConfigurableApplicationContext context, String key) throws Exception {
        return switch (key) {
            case "tiffinbox.cooks" -> "the bean's own field: OrderQueue.cooks = " + read(context, "com.tiffinbox.OrderQueue", "cooks");
            case "tiffinbox.days" -> "the bean's own field: TiffinBoxServer.days = " + read(context, "com.tiffinbox.web.TiffinBoxServer", "days");
            case "tiffinbox.jdbc-url" -> "the bean's own field: Database.url = " + read(context, "com.tiffinbox.Database", "url");
            case "tiffinbox.port" -> "the bean's own field: TiffinBoxServer.port = " + read(context, "com.tiffinbox.web.TiffinBoxServer", "port");
            default -> "the bean's own field: (no TiffinBox bean reads " + key + ")";
        };
    }

    private static Object read(ConfigurableApplicationContext context, String type, String name) throws Exception {
        Class<?> c = Class.forName(type);
        Field f = c.getDeclaredField(name);
        f.setAccessible(true);
        return f.get(context.getBean(c));
    }
}
