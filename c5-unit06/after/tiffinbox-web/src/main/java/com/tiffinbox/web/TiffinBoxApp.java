package com.tiffinbox.web;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * The description the container reads instead of Wiring.java: where the objects are. Nothing here says what to
 * build first.
 *
 * Course 5, unit 04: @EnableAutoConfiguration asks Boot to read its list of configuration classes (one
 * AutoConfiguration.imports file per module) and to register the ones whose conditions hold. Nothing else changes.
 *
 * Course 5, unit 06: no @PropertySource any more. TiffinBox's four values live in application.properties, the file
 * Boot finds by name while it prepares the environment, before the container starts. A @PropertySource file is read
 * later, during refresh: it ranks below every source Boot adds, and it arrives after Boot has read keys such as
 * logging.level.tiffinbox and spring.main.banner-mode.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan("com.tiffinbox")
public class TiffinBoxApp {
}
