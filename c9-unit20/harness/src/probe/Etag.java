package probe;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

/**
 * Course 9, unit 04 - the harness's, never TiffinBox's (copied from the S1 probe's Etag.java): the old surface's PLANT (S9.14's self-test) - Spring's
 * ShallowEtagHeaderFilter registered on every path. The seven record bodies, so their md5 must not move; the old surface
 * records headers, so its md5 must (its ETag lines named).
 * Course 9, unit 20 (adapted, a named diff): the patterns are a run flag, --probe.etag.paths (default /* - the loser), so one class
 * gives the harness's /* copy, the unfiltered-bill copy (/api/v1/*, no exclusion) and Chrome leg B's page copy (/dashboard).
 */
@Configuration(proxyBeanMethods = false)
public class Etag {
    @Bean
    FilterRegistrationBean<ShallowEtagHeaderFilter> plantedShallowEtags(@Value("${probe.etag.paths:/*}") String[] paths) {
        FilterRegistrationBean<ShallowEtagHeaderFilter> reg = new FilterRegistrationBean<>(new ShallowEtagHeaderFilter());
        reg.addUrlPatterns(paths);
        reg.setName("plantedShallowEtags");
        return reg;
    }
}
