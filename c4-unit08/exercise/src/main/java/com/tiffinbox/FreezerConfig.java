package com.tiffinbox;

import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

/** The description. There is exactly one thing wrong in here. */
@Configuration
public class FreezerConfig {

    @Bean @Scope(ConfigurableBeanFactory.SCOPE_PROTOTYPE)
    Freezer freezer() { return new Freezer(); }
}
