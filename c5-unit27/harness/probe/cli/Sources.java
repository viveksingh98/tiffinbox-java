package probe.cli;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

import java.util.Map;

/**
 * The harness's reading of where a @PropertySource file ranks (the course's, never TiffinBox's): a configuration class with
 * one @PropertySource file (probe/sources.properties, one key), started by Boot without a web server, on TiffinBox's class
 * path and in a folder with its config tree - first as is, then (option probe.defaults=yes) with default properties set in
 * code, which Boot keeps as a source of its own. It prints the environment's sources in order, and where the file stands.
 */
@Configuration
@PropertySource("classpath:probe/sources.properties")
public class Sources {

    public static void main(String[] args) {
        SpringApplication app = new SpringApplication(Sources.class);
        app.setWebApplicationType(WebApplicationType.NONE);
        boolean defaults = String.join(" ", args).contains("--probe.defaults=yes");
        if (defaults) {
            app.setDefaultProperties(Map.of("probe.key", "from default properties"));
        }
        try (ConfigurableApplicationContext ctx = app.run(args)) {
            int n = 0, at = 0;
            StringBuilder names = new StringBuilder();
            for (org.springframework.core.env.PropertySource<?> s : ctx.getEnvironment().getPropertySources()) {
                n++;
                names.append(n == 1 ? "" : " · ").append(n).append(' ').append(s.getName());
                if (s.getName().contains("probe/sources.properties")) {
                    at = n;
                }
            }
            System.out.println("harness: default properties " + (defaults ? "set" : "not set") + " · sources " + n + ": " + names);
            System.out.println("harness: the @PropertySource file ranks " + at + " of " + n + " · probe.key = "
                    + ctx.getEnvironment().getProperty("probe.key"));
        }
    }
}
