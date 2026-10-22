package probe.web;

import java.util.List;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

/**
 * The course's harness, never TiffinBox's: the third way - Spring's CorsFilter, a servlet filter, in a filter registration near the
 * front of Tomcat's chain, with a rule for /probe/filter/** only: one origin, GET and PUT, any request header. A bare
 * CorsConfiguration, as the filter takes it: no defaults are applied to it.
 */
@Configuration(proxyBeanMethods = false)
public class FilterCors {

    @Bean
    FilterRegistrationBean<CorsFilter> corsFilter() {
        CorsConfiguration c = new CorsConfiguration();
        c.setAllowedOrigins(List.of("http://127.0.0.1:19486"));
        c.setAllowedMethods(List.of("GET", "PUT"));
        c.addAllowedHeader("*");
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/probe/filter/**", c);
        FilterRegistrationBean<CorsFilter> b = new FilterRegistrationBean<>(new CorsFilter(source));
        b.setOrder(Ordered.HIGHEST_PRECEDENCE + 10);
        return b;
    }
}
