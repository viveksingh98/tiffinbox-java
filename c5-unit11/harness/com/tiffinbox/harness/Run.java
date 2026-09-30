package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringApplicationRunListener;
import org.springframework.boot.context.properties.source.ConfigurationProperty;
import org.springframework.boot.context.properties.source.ConfigurationPropertyName;
import org.springframework.boot.context.properties.source.ConfigurationPropertySource;
import org.springframework.boot.context.properties.source.ConfigurationPropertySources;
import org.springframework.boot.origin.Origin;
import org.springframework.boot.origin.OriginLookup;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

/**
 * What the harness shares. {@link #tiffinbox} runs TiffinBox's OWN main, unchanged - the tree's
 * {@code TiffinBoxServer.main(args)} - inside Boot's {@code SpringApplication.withHook}, whose run listener is handed the
 * context that main starts.
 *
 * <p>No class in this harness carries a class-level annotation, so TiffinBox's {@code @ComponentScan("com.tiffinbox")},
 * which registers annotated components only, never picks one up.
 *
 * <p><b>This harness never prints a value.</b> The key it is pointed at is a secret, so every value - the WINNER, what each
 * property source holds, the record's component - is printed as its length alone. Only {@link Record} prints the record
 * whole, to count what such a print carries: a record's default toString() prints every component, the token included.
 */
final class Run {

    private static volatile ConfigurableApplicationContext ready;

    private Run() {
    }

    /** Runs TiffinBox's main and returns the context once it is ready. */
    static ConfigurableApplicationContext tiffinbox(String[] args) {
        try {
            SpringApplication.withHook(app -> new SpringApplicationRunListener() {
                @Override
                public void ready(ConfigurableApplicationContext context, Duration timeTaken) {
                    ready = context;
                }
            }, () -> TiffinBoxServer.main(args));
        } catch (RuntimeException | Error e) {
            // Boot has printed its own report by now. Name the type, then rethrow the same exception: the exit code stays
            // the one TiffinBox's own run gives.
            System.out.println("the exception TiffinBox's main threw: " + e.getClass().getName());
            throw e;
        }
        return ready;
    }

    /** A value as this harness shows it: its length, never the value. */
    static String shown(Object value) {
        return value == null ? "-" : "(" + String.valueOf(value).length() + " characters)";
    }

    /** The environment's property sources, in the order Boot asks them: the first one that holds a key answers it. */
    static List<PropertySource<?>> sources(ConfigurableEnvironment env) {
        List<PropertySource<?>> sources = new ArrayList<>();
        env.getPropertySources().forEach(sources::add);
        return sources;
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
     * Who answers a key: the WINNER's length and the source it came from, then every source in order with the length of
     * what it holds for the key under that exact name, and Boot's {@code Origin} where the source tracks one.
     */
    static List<String> stack(ConfigurableEnvironment env, String key) {
        List<PropertySource<?>> sources = sources(env);
        ConfigurationProperty found = viewFinds(env, key);
        PropertySource<?> answering = found == null ? null : (PropertySource<?>) found.getSource().getUnderlyingSource();
        int from = answering == null ? 0 : sources.indexOf(answering) + 1;
        List<String> out = new ArrayList<>();
        out.add("KEY " + key + " -> WINNER " + shown(env.getProperty(key)) + " · from source " + from + " of " + sources.size()
                + ", " + (answering == null ? "(none)" : answering.getName()));
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
            out.add(String.format("  %2d %-26s %s%s%s", i + 1, ps.getName(), shown(v),
                    view ? "   (Boot's view over the sources below it)" : "", origin));
        }
        return out;
    }

    /** What the folder TiffinBox starts in holds, of the two things application.yaml imports from it. */
    static String folderLine() {
        return "the working folder: tiffinbox-local.yaml " + (Files.exists(Path.of("tiffinbox-local.yaml")) ? "present" : "absent")
                + " · secrets/ " + (Files.isDirectory(Path.of("secrets")) ? "present" : "absent");
    }
}
