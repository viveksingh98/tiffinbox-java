package probe.json;

import org.springframework.boot.jackson.autoconfigure.JsonMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tools.jackson.databind.DeserializationFeature;

/**
 * The course's harness, never TiffinBox's (outside com.tiffinbox, joined by --spring.main.sources). Customising Boot's mapper in
 * code: one JsonMapperBuilderCustomizer bean, which Boot hands the builder it makes jacksonJsonMapper with - here, to refuse
 * unknown properties. Spring's own mapper only: Actuator builds its own.
 */
@Configuration(proxyBeanMethods = false)
public class Strict {

    @Bean
    JsonMapperBuilderCustomizer strictJson() {
        return builder -> builder.enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    }
}
