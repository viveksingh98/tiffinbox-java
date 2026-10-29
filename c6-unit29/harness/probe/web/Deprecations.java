package probe.web;

import java.net.URI;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.accept.StandardApiVersionDeprecationHandler;

/** The course's harness: version 1.0 marked for removal - deprecated from 1 October 2026, its sunset (the date it goes) 1 April
 *  2027, and a link that explains it. One bean of spring-web's StandardApiVersionDeprecationHandler: Boot hands it to Spring MVC's
 *  versioning, which writes the headers on every answer whose request carried 1.0. */
@Configuration
public class Deprecations {
    @Bean
    StandardApiVersionDeprecationHandler versionDeprecations() {
        StandardApiVersionDeprecationHandler h = new StandardApiVersionDeprecationHandler();
        h.configureVersion("1.0")
         .setDeprecationDate(ZonedDateTime.of(2026, 10, 1, 0, 0, 0, 0, ZoneOffset.UTC))
         .setSunsetDate(ZonedDateTime.of(2027, 4, 1, 0, 0, 0, 0, ZoneOffset.UTC))
         .setDeprecationLink(URI.create("http://127.0.0.1/docs/menu-1.0"));
        return h;
    }
}
