package probe.web;

import jakarta.servlet.DispatcherType;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

import java.util.EnumSet;

/**
 * The course's harness, never TiffinBox's: a filter registration - a FilterRegistrationBean, Boot's object for registering a filter
 * with Tomcat with a name, an order and its dispatch types chosen in code. It registers EveryFilter for every dispatch type
 * (REQUEST, ERROR, ASYNC, FORWARD, INCLUDE), as "everyFilter", at the order --probe.every.order gives (0 unless named).
 */
@Configuration(proxyBeanMethods = false)
public class EveryRegistration {

    @Bean
    FilterRegistrationBean<EveryFilter> everyFilter(Environment env) {
        FilterRegistrationBean<EveryFilter> b = new FilterRegistrationBean<>(new EveryFilter());
        b.setDispatcherTypes(EnumSet.allOf(DispatcherType.class));
        b.setOrder(env.getProperty("probe.every.order", Integer.class, 0));
        return b;
    }
}
