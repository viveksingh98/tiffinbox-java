package probe;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (copied from the S1 probe's Etag.java): the old surface's PLANT (S9.14's self-test) - Spring's
 * ShallowEtagHeaderFilter registered on every path. The seven record bodies, so their md5 must not move; the old surface
 * records headers, so its md5 must (its ETag lines named).
 */
@Configuration(proxyBeanMethods = false)
public class Etag {
    @Bean
    FilterRegistrationBean<ShallowEtagHeaderFilter> plantedShallowEtags() {
        FilterRegistrationBean<ShallowEtagHeaderFilter> reg = new FilterRegistrationBean<>(new ShallowEtagHeaderFilter());
        reg.addUrlPatterns("/*");
        reg.setName("plantedShallowEtags");
        return reg;
    }
}
