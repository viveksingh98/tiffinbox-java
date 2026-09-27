package com.tiffinbox.web;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * The description the container reads instead of Wiring.java: where the objects are, and where the
 * three values they need live. Nothing here says what to build first.
 *
 * Course 5, unit 04: @EnableAutoConfiguration asks Boot to read its list of configuration classes (one
 * AutoConfiguration.imports file per module) and to register the ones whose conditions hold. Nothing else changes.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan("com.tiffinbox")
@PropertySource("classpath:tiffinbox.properties")
public class TiffinBoxApp {
}
