package probe.web;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The course's harness, never TiffinBox's: PlainFilter - its class annotated @Order(1) - wrapped in a FilterRegistrationBean that sets
 * no order of its own. Joined instead of PlainFilter, it shows whose order Tomcat's chain follows: the registration's, or the class's.
 */
@Configuration(proxyBeanMethods = false)
public class PlainRegistration {

    @Bean
    FilterRegistrationBean<PlainFilter> wrappedPlain() {
        return new FilterRegistrationBean<>(new PlainFilter());
    }
}
