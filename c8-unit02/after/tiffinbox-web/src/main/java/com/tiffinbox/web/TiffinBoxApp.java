package com.tiffinbox.web;

import com.tiffinbox.TiffinBoxProperties;
import com.tiffinbox.jdbc.JdbcNames;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.persistence.autoconfigure.EntityScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.data.jdbc.repository.config.EnableJdbcRepositories;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

/**
 * The description the container reads instead of Wiring.java: where the objects are. Nothing here says what to
 * build first.
 *
 * Course 5, unit 04: @EnableAutoConfiguration asks Boot to read its list of configuration classes (one
 * AutoConfiguration.imports file per module) and to register the ones whose conditions hold. Nothing else changes.
 *
 * Course 5, unit 06: no @PropertySource any more. TiffinBox's four values live in application.properties, the file
 * Boot finds by name while it prepares the environment, before the container starts. A @PropertySource file is read
 * later, during refresh: it ranks below every source Boot adds but one - default properties, set in code, which Boot
 * keeps last - and it arrives after Boot has read keys such as logging.level.tiffinbox and spring.main.banner-mode.
 *
 * Course 5, unit 07: the four values moved to application.yaml, which Boot finds by name the same way - one level of
 * nesting per dot - beside a meal-types list and a second document for the profile "rush". application.properties is
 * deleted: left in the same folder, it would rank above the YAML file.
 *
 * Course 5, unit 08: @EnableConfigurationProperties registers TiffinBoxProperties, the record in tiffinbox-core that
 * Boot's binder fills with every key under "tiffinbox" - the list included. OrderQueue and TiffinBoxServer take the
 * record (Course 7, unit 36: the retired Database class took it too), so no @Value placeholder is left.
 *
 * Course 7, unit 03: @EntityScan names the package Hibernate's entities are looked for in. Without it Boot looks in the
 * auto-configuration package - this class's own, com.tiffinbox.web - and CustomerEntity lives in tiffinbox-core's
 * com.tiffinbox: the context still starts, and the first query fails, "Could not resolve root entity 'CustomerEntity'". A
 * context that starts is not evidence the entity is mapped (../c7-unit03, scan).
 *
 * Course 7, unit 15: @EnableJpaRepositories names the package Spring Data's repository interfaces are looked for in. Without
 * it Boot looks in the auto-configuration package, com.tiffinbox.web, and CustomerEntityRepository lives in tiffinbox-core's
 * com.tiffinbox: the start log says "Found 0 JPA repository interfaces", and the start fails only because CustomerRepository's
 * constructor asks for the bean - "required a bean of type 'com.tiffinbox.CustomerEntityRepository' that could not be found"
 * (../c7-unit15, scan).
 *
 * Course 7, unit 38: @EnableJpaAuditing switches on Spring Data's auditing: the AuditingEntityListener CustomerEntity names fills
 * its createdAt and updatedAt before each INSERT and UPDATE. Without it the listener sets nothing and both columns stay NULL. No
 * AuditorAware bean: who made a change waits for a signed-in user, Course 10, Spring Security (../c7-unit38, audit).
 *
 * Course 8, unit 02: a second Spring Data module, Spring Data JDBC, beside Spring Data JPA. With both on the class path Spring
 * Data enters strict repository configuration mode: each module claims a repository by its domain type's annotation -
 * Jakarta Persistence's @Entity for JPA, Spring Data Relational's @Table for JDBC - and logs "Could not safely identify store
 * assignment" for the other's. @EnableJdbcRepositories names the JDBC module's package, com.tiffinbox.jdbc: without it Boot's
 * own scan starts at com.tiffinbox.web and finds none ("Found 0 JDBC repository interfaces"). @Import(JdbcNames.class) makes
 * the module's SQL unquoted, as V1's names are (on H2 the quoted names are not found). @EnableJpaRepositories still scans
 * com.tiffinbox, and com.tiffinbox.jdbc with it: CustomerAggregates is skipped there, its CustomerRow is no entity.
 */
@Configuration
@EnableAutoConfiguration
@ComponentScan("com.tiffinbox")
@EnableConfigurationProperties(TiffinBoxProperties.class)
@EntityScan("com.tiffinbox")
@EnableJpaRepositories("com.tiffinbox")
@EnableJdbcRepositories("com.tiffinbox.jdbc")
@Import(JdbcNames.class)
@EnableJpaAuditing
public class TiffinBoxApp {
}
