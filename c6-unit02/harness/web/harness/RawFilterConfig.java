package harness;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * The harness's filter registration - the course's, never TiffinBox's; it joins a run by --spring.main.sources. One raw
 * filter, on every path (/*).
 */
@Configuration(proxyBeanMethods = false)
public class RawFilterConfig {

    @Bean
    FilterRegistrationBean<RawFilter> rawFilter() {
        FilterRegistrationBean<RawFilter> bean = new FilterRegistrationBean<>(new RawFilter());
        bean.addUrlPatterns("/*");
        return bean;
    }
}
