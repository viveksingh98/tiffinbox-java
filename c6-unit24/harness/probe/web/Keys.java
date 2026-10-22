package probe.web;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.EnumerablePropertySource;
import org.springframework.core.env.PropertySource;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.TreeSet;

/**
 * The course's harness, never TiffinBox's: what DevTools adds to Spring's environment, read off the running application once it
 * has started. It prints the JVM's locale; every property source whose name says devtools, with how many keys it holds and each
 * key with its value, sorted by key; then what the environment as a whole answers for the template and resource keys a lesson names
 * (null: nobody set it). Each line goes through Trace.
 */
@Component
public class Keys implements ApplicationRunner {

    private static final List<String> NAMED = List.of("spring.thymeleaf.cache", "spring.template.provider.cache",
            "spring.web.resources.cache.period", "spring.web.resources.chain.cache", "server.servlet.session.persistent");

    private final ConfigurableEnvironment env;

    Keys(ConfigurableEnvironment env) {
        this.env = env;
    }

    @Override
    public void run(ApplicationArguments args) {
        Trace.log("Keys the JVM's locale: " + Locale.getDefault());
        int sources = 0;
        for (PropertySource<?> s : env.getPropertySources()) {
            if (!s.getName().toLowerCase(Locale.ROOT).contains("devtools") || !(s instanceof EnumerablePropertySource<?> e)) {
                continue;
            }
            sources++;
            String[] names = e.getPropertyNames();
            Trace.log("Keys the property source " + s.getName() + ": " + names.length + " keys");
            for (String k : new TreeSet<>(Arrays.asList(names))) {
                Trace.log("Keys   " + k + " = " + e.getProperty(k));
            }
        }
        Trace.log("Keys property sources whose name says devtools: " + sources);
        for (String k : NAMED) {
            Trace.log("Keys the environment's " + k + ": " + env.getProperty(k));
        }
    }
}
