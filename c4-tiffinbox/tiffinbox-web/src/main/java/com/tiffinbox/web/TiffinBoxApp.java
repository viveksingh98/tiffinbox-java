package com.tiffinbox.web;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

/**
 * The description the container reads instead of Wiring.java: where the objects are, and where the
 * three values they need live. Nothing here says what to build first.
 */
@Configuration
@ComponentScan("com.tiffinbox")
@PropertySource("classpath:tiffinbox.properties")
public class TiffinBoxApp {
}
