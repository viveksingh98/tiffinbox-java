package probe.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.web.servlet.config.annotation.InterceptorRegistration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.Locale;

/**
 * The course's harness, never TiffinBox's: a WebMvcConfigurer that adds Interceptor to Spring MVC's registry, with no path pattern -
 * so it runs for every handler Spring MVC's handler mappings give it. --probe.exclude=PATTERN adds one excludePathPatterns for one run.
 * It prints the JVM's locale once, when Spring makes it.
 */
@Configuration(proxyBeanMethods = false)
public class Hooks implements WebMvcConfigurer {

    private final String exclude;

    public Hooks(Environment env) {
        this.exclude = env.getProperty("probe.exclude");
        Trace.log("Hooks           the JVM's locale: " + Locale.getDefault());
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        InterceptorRegistration r = registry.addInterceptor(new Interceptor());
        if (exclude != null) {
            r.excludePathPatterns(exclude);
        }
    }
}
