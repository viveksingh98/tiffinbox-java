package com.tiffinbox.harness;

import com.tiffinbox.web.TiffinBoxServer;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.BeanDefinitionRegistryPostProcessor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.SpringApplicationRunListener;
import org.springframework.boot.bootstrap.ConfigurableBootstrapContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.PropertySource;

import java.net.URL;
import java.nio.file.Path;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * WHEN is a key there? {@code When <key,key,...> <the arguments TiffinBox's main gets>}.
 *
 * <p>Runs TiffinBox's own main (as {@link Winner} does) with a run listener that reads the keys at five steps of
 * {@code SpringApplication.run}, and prints them only after start-up, so nothing interleaves with Boot's own lines:
 * <ol>
 *   <li><b>environment prepared</b> - Boot's own listeners have just run for this step (its logging listener among
 *       them; ours is added after them);</li>
 *   <li><b>context loaded</b> - the last step before refresh (refresh: the container reading your configuration and
 *       building your objects);</li>
 *   <li><b>refresh: row-2 step begins</b> - a definition-registry hook of ours, handed to the context directly, so the
 *       container runs it BEFORE the ones it finds as beans - ConfigurationClassPostProcessor, which reads
 *       {@code @ComponentScan}, {@code @Import} and {@code @PropertySource}, is one of those;</li>
 *   <li><b>refresh: row-2 step done</b> - the same hook's second callback, which runs after every definition-registry
 *       hook has run;</li>
 *   <li><b>context refreshed</b>.</li>
 * </ol>
 * At each step: each key's value, the number of property sources, and whether TiffinBox's own logger, the JDK's
 * {@code System.getLogger("tiffinbox")} that TiffinBoxServer logs its route lines through, would log DEBUG.
 * Then where each value was found, and which file stands behind each class-path source of that name.
 */
public final class When {

    private static final List<String[]> rows = new ArrayList<>();
    private static volatile ConfigurableApplicationContext ctx;

    public static void main(String[] args) throws Exception {
        String[] keys = args[0].split(",");
        String[] tiffinboxArgs = Arrays.copyOfRange(args, 1, args.length);
        SpringApplication.withHook(app -> new SpringApplicationRunListener() {
            @Override
            public void environmentPrepared(ConfigurableBootstrapContext bootstrap, ConfigurableEnvironment env) {
                row("environment prepared", env, keys);
            }

            @Override
            public void contextLoaded(ConfigurableApplicationContext context) {
                row("context loaded", context.getEnvironment(), keys);
                context.addBeanFactoryPostProcessor(new BeanDefinitionRegistryPostProcessor() {
                    @Override
                    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) {
                        row("refresh: row-2 step begins", context.getEnvironment(), keys);
                    }

                    @Override
                    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
                        row("refresh: row-2 step done", context.getEnvironment(), keys);
                    }
                });
            }

            @Override
            public void started(ConfigurableApplicationContext context, Duration timeTaken) {
                row("context refreshed", context.getEnvironment(), keys);
            }

            @Override
            public void ready(ConfigurableApplicationContext context, Duration timeTaken) {
                ctx = context;
            }
        }, () -> TiffinBoxServer.main(tiffinboxArgs));
        try {
            StringBuilder head = new StringBuilder(String.format("%-30s", "step of SpringApplication.run"));
            for (String k : keys) {
                head.append(String.format("%-26s", k));
            }
            System.out.println(head.append(String.format("%-9s%s", "sources", "logger tiffinbox logs DEBUG")));
            for (String[] r : rows) {
                StringBuilder b = new StringBuilder(String.format("%-30s", r[0]));
                for (int i = 0; i < keys.length; i++) {
                    b.append(String.format("%-26s", r[1 + i]));
                }
                System.out.println(b.append(String.format("%-9s%s", r[1 + keys.length], r[2 + keys.length])));
            }
            ConfigurableEnvironment env = ctx.getEnvironment();
            System.out.println("where each value was found, after refresh:");
            for (String k : keys) {
                System.out.println("  " + k + "  <-  " + firstHolder(env, k));
            }
            for (String name : List.of("tiffinbox.properties", "application.properties")) {
                URL u = When.class.getClassLoader().getResource(name);
                System.out.println("the file the class path gives for " + name + ": " + (u == null ? "none" : shorten(u)));
            }
        } finally {
            ctx.close();
        }
    }

    static void row(String step, ConfigurableEnvironment env, String[] keys) {
        String[] r = new String[keys.length + 3];
        r[0] = step;
        for (int i = 0; i < keys.length; i++) {
            String v = env.getProperty(keys[i]);
            r[1 + i] = v == null ? "-" : v;
        }
        r[1 + keys.length] = String.valueOf(env.getPropertySources().size());
        r[2 + keys.length] = System.getLogger("tiffinbox").isLoggable(System.Logger.Level.DEBUG) ? "yes" : "no";
        rows.add(r);
    }

    static String firstHolder(ConfigurableEnvironment env, String key) {
        for (PropertySource<?> ps : env.getPropertySources()) {
            if (!Winner.isView(ps) && ps.getProperty(key) != null) {
                return ps.getName();
            }
        }
        return "(none)";
    }

    /** A jar entry as jarname!/entry; a plain file relative to the working directory. */
    static String shorten(URL u) throws Exception {
        if ("jar".equals(u.getProtocol())) {
            String s = u.getPath();
            return s.substring(s.lastIndexOf('/', s.indexOf("!/")) + 1);
        }
        return Path.of("").toAbsolutePath().relativize(Path.of(u.toURI())).toString();
    }
}
