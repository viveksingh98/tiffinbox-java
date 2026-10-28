package probe.web;

import jakarta.servlet.DispatcherType;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** The course's harness, never TiffinBox's: ChainDump, registered for the REQUEST and the ERROR dispatch. */
@Configuration(proxyBeanMethods = false)
public class Traced {

    @Bean
    FilterRegistrationBean<ChainDump> chainDump() {
        var r = new FilterRegistrationBean<>(new ChainDump());
        r.setName("chainDump");
        r.setDispatcherTypes(DispatcherType.REQUEST, DispatcherType.ERROR);
        return r;
    }
}
