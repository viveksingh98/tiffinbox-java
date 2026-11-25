package com.tiffinbox.web;

import io.swagger.v3.core.converter.ModelConverters;
import io.swagger.v3.oas.models.examples.Example;
import io.swagger.v3.oas.models.media.Content;
import io.swagger.v3.oas.models.media.MediaType;
import io.swagger.v3.oas.models.media.Schema;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.ProblemDetail;
import tools.jackson.databind.json.JsonMapper;

import java.util.LinkedHashMap;
import java.util.List;

/**
 * Course 9, unit 09 - the harness's MIRROR of mechanism B, measured, not shipped: one package-private class whose OperationCustomizer
 * adds the same error responses as mechanism A's annotations, keyed by handler method (Class#method), and whose OpenApiCustomizer adds
 * Framework's ProblemDetail schema to components. Copied into a scratch mirror of before (.harness/loser) by receipts.sh; never in
 * c9-tiffinbox.
 */
@Configuration(proxyBeanMethods = false)
class TiffinBoxErrorDocs {

    /** handler, status, the response's description, the example's name, the example (an answer the wire sent) */
    private static final List<String[]> ROWS = List.of(
            new String[] {"TiffinBoxServer#customer", "404", "Customer not found", "customer-not-found", "{\"detail\":\"no customer named Nobody\",\"instance\":\"/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}"},
            new String[] {"TiffinBoxServer#add", "400", "Idempotency-Key is malformed", "idempotency-key-malformed", "{\"detail\":\"The Idempotency-Key header must be one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is malformed\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-malformed\"}"},
            new String[] {"TiffinBoxServer#add", "409", "A request is outstanding for this Idempotency-Key", "idempotency-key-outstanding", "{\"detail\":\"A request with this Idempotency-Key is still being processed. Retry it later with the same key.\",\"status\":409,\"title\":\"A request is outstanding for this Idempotency-Key\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-outstanding\"}"},
            new String[] {"TiffinBoxServer#add", "422", "Idempotency-Key is already used", "idempotency-key-reused", "{\"detail\":\"This Idempotency-Key was first used with a different request. Use a new key for a new request.\",\"status\":422,\"title\":\"Idempotency-Key is already used\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-reused\"}"},
            new String[] {"CustomerReads#one", "404", "Customer not found", "customer-not-found", "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}"},
            new String[] {"CustomerPatches#merge", "404", "Customer not found", "customer-not-found", "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}"},
            new String[] {"CustomerPatches#jsonPatch", "404", "Customer not found", "customer-not-found", "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}"},
            new String[] {"CustomerPauses#add", "400", "Idempotency-Key is missing or malformed", "idempotency-key-missing", "{\"detail\":\"This operation requires an Idempotency-Key header: one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is missing\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-missing\"}"},
            new String[] {"CustomerPauses#add", "400", "Idempotency-Key is missing or malformed", "idempotency-key-malformed", "{\"detail\":\"The Idempotency-Key header must be one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is malformed\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-malformed\"}"},
            new String[] {"CustomerPauses#add", "404", "Customer not found", "customer-not-found", "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody/pauses\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}"},
            new String[] {"CustomerPauses#add", "409", "A request is outstanding for this Idempotency-Key", "idempotency-key-outstanding", "{\"detail\":\"A request with this Idempotency-Key is still being processed. Retry it later with the same key.\",\"status\":409,\"title\":\"A request is outstanding for this Idempotency-Key\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-outstanding\"}"},
            new String[] {"CustomerPauses#add", "422", "Idempotency-Key is already used", "idempotency-key-reused", "{\"detail\":\"This Idempotency-Key was first used with a different request. Use a new key for a new request.\",\"status\":422,\"title\":\"Idempotency-Key is already used\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-reused\"}"},
            new String[] {"CustomerPauses#one", "404", "Not Found", "not-found", "{\"detail\":\"no pause 1 for a customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody/pauses/1\",\"status\":404,\"title\":\"Not Found\"}"});

    @Bean
    OperationCustomizer errorResponses() {
        JsonMapper json = JsonMapper.builder().build();
        return (op, hm) -> {
            String key = hm.getBeanType().getSimpleName() + "#" + hm.getMethod().getName();
            for (String[] r : ROWS) {
                if (!r[0].equals(key)) continue;
                if (op.getResponses() == null) op.setResponses(new ApiResponses());
                ApiResponse resp = op.getResponses().get(r[1]);
                if (resp == null) {
                    resp = new ApiResponse().description(r[2]).content(new Content().addMediaType("application/problem+json",
                            new MediaType().schema(new Schema<>().$ref("#/components/schemas/ProblemDetail"))));
                    op.getResponses().addApiResponse(r[1], resp);
                }
                resp.getContent().get("application/problem+json").addExamples(r[3], new Example().description(r[3]).value(json.readValue(r[4], LinkedHashMap.class)));
            }
            return op;
        };
    }

    @Bean
    OpenApiCustomizer problemDetailSchema() {
        return api -> ModelConverters.getInstance().read(ProblemDetail.class).forEach((k, v) -> api.getComponents().addSchemas(k, v));
    }
}
