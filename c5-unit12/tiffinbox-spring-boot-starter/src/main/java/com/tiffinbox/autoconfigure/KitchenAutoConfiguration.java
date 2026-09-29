package com.tiffinbox.autoconfigure;

import com.tiffinbox.kitchen.Kitchen;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;

/** A configuration class, one condition, and one line in META-INF/spring/…AutoConfiguration.imports. */
@AutoConfiguration
@EnableConfigurationProperties(KitchenProperties.class)
public class KitchenAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    Kitchen kitchen(KitchenProperties props) {
        return new Kitchen(props.name(), props.cooks());
    }
}
