package probe.u03;

import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.relational.core.mapping.RelationalMappingContext;

/**
 * Unit 03's harness switch, never the anchor's (BLUE #2's sketch): single-query loading on the mapping context, before it
 * initialises, only when the JVM runs with -Du03.sq=true. Without the property it leaves the context as the anchor has it
 * (off - printed by the harness from isSingleQueryLoadingEnabled() in every JVM). JdbcNames's Q is the anchor's own.
 */
@Configuration(proxyBeanMethods = false)
public class SingleQuery {

    @Bean
    static BeanPostProcessor singleQueryLoading() {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessBeforeInitialization(Object bean, String name) {
                if (bean instanceof RelationalMappingContext c && Boolean.getBoolean("u03.sq")) {
                    c.setSingleQueryLoadingEnabled(true);
                }
                return bean;
            }
        };
    }
}
