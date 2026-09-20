package com.tiffinbox;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** The description. Do not change this file. */
@Configuration
public class KitchenConfig {
    @Bean Kitchen kitchen() { return new Kitchen(); }
}
