package harness;

import java.util.List;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The harness's servlet registration - the course's, never TiffinBox's; it joins a run by --spring.main.sources. One raw
 * servlet, on three kinds of pattern: an exact path, a path ending in /*, and an extension.
 */
@Configuration(proxyBeanMethods = false)
public class RawServletConfig {

    @Bean
    ServletRegistrationBean<RawServlet> rawServlet() {
        ServletRegistrationBean<RawServlet> bean = new ServletRegistrationBean<>(new RawServlet());
        bean.setUrlMappings(List.of("/raw", "/raw/*", "*.tiff"));
        return bean;
    }
}
