package probe.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * The course's harness, never TiffinBox's: a global rule for /probe/global/** that lets any origin in ("*") and allows credentials
 * (cookies, an Authorization header) too - a combination Spring refuses.
 */
@Configuration(proxyBeanMethods = false)
public class StarCreds implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/probe/global/**").allowedOrigins("*").allowCredentials(true);
    }
}
