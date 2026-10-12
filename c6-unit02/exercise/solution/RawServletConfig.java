package harness;

import java.util.List;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The exercise's solution - the shipped registration with one pattern more: the extension *.menu, beside the exact path
 * /raw and the path /raw/*.
 */
@Configuration(proxyBeanMethods = false)
public class RawServletConfig {

    @Bean
    ServletRegistrationBean<RawServlet> rawServlet() {
        ServletRegistrationBean<RawServlet> bean = new ServletRegistrationBean<>(new RawServlet());
        bean.setUrlMappings(List.of("/raw", "/raw/*", "*.menu"));
        return bean;
    }
}
