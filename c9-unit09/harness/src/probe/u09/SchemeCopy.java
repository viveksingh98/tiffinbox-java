package probe.u09;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Course 9, unit 09 - the harness's COPY of the spec, never TiffinBox's: a document customizer (springdoc's OpenApiCustomizer) that adds
 * components.securitySchemes.bearer (http, bearer, JWT) and a global security requirement to the SERVED document of a harness-joined start.
 * The S2 probe's probe.DeclaredScheme (read as the draft) was a second OpenAPI bean; on this tree TiffinBoxOpenApi.openApi() already is
 * the one OpenAPI bean, so the copy edits the document instead of adding a bean. It declares a scheme; nothing enforces it.
 */
@Configuration(proxyBeanMethods = false)
public class SchemeCopy {

    @Bean
    OpenApiCustomizer declaredBearer() {
        return api -> {
            if (api.getComponents() == null) api.setComponents(new Components());
            api.getComponents().addSecuritySchemes("bearer", new SecurityScheme().type(SecurityScheme.Type.HTTP).scheme("bearer").bearerFormat("JWT"));
            api.addSecurityItem(new SecurityRequirement().addList("bearer"));
        };
    }
}
