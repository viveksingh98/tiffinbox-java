package com.tiffinbox.web;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Course 9, unit 08: gives the document TiffinBox serves at {@code /v3/api-docs} its own {@code info} - the title "TiffinBox" and the
 * version "1.0" - in place of springdoc's "OpenAPI definition" and "v0", and nothing else. It adds no server, no tag, no error response
 * and no security scheme: the lessons that add those regenerate the committed file in their own commits.
 *
 * <p>{@code info.version} is the DOCUMENT's version, not the version of any route: no route's address or answer carries it
 * (Versioning Strategies names the versions its routes carry; this class names none).
 *
 * <p>A change to this class changes the served document, so {@code OpenApiSpecTest} fails until
 * {@code src/test/resources/openapi/tiffinbox.json} is written again from the running application, in the same commit.
 */
@Configuration(proxyBeanMethods = false)
final class TiffinBoxOpenApi {

    @Bean
    OpenAPI openApi() {
        return new OpenAPI().info(new Info().title("TiffinBox").version("1.0"));
    }
}
