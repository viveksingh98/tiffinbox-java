package harness;

import java.util.List;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The exercise's servlet registration - yours to change (exercise/README.md). As shipped, the raw servlet is registered on
 * two patterns only: an exact path and a path ending in /*. Your turn: register it on *.menu as well, then run
 * exercise/try.sh again and read which pattern matched each request.
 */
@Configuration(proxyBeanMethods = false)
public class RawServletConfig {

    @Bean
    ServletRegistrationBean<RawServlet> rawServlet() {
        ServletRegistrationBean<RawServlet> bean = new ServletRegistrationBean<>(new RawServlet());
        bean.setUrlMappings(List.of("/raw", "/raw/*"));
        return bean;
    }
}
