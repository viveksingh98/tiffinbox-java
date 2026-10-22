package probe.web;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * The course's harness, never TiffinBox's: the same rule as CorsRoutes' @CrossOrigin - one origin, GET and PUT - given to
 * /probe/global/** through Spring MVC's CORS registry (WebMvcConfigurer.addCorsMappings), the global way.
 */
@Configuration(proxyBeanMethods = false)
public class GlobalCors implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/probe/global/**").allowedOrigins("http://127.0.0.1:19486").allowedMethods("GET", "PUT");
    }
}
