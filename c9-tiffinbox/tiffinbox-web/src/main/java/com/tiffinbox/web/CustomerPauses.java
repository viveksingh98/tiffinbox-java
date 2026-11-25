package com.tiffinbox.web;

import com.tiffinbox.PauseEntity;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Course 9, unit 04: the public API's first route - a pause, created under the customer, answered 201 with the new pause's
 * Location, which GET reads back. The Idempotency-Key is required here (IdempotencyKeyFilter): a pause sent twice under one key is
 * one pause.
 */
@RestController
final class CustomerPauses {

    private final Pauses pauses;

    CustomerPauses(Pauses pauses) {
        this.pauses = pauses;
    }

    // Course 9, unit 09: the documented not-found problem - Framework's ProblemDetail schema, an example equal to the answer this route sent; and the key's problems (IdempotencyKeyFilter), documented here - examples equal to the answers the filter sent; the header itself is not named
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "400", description = "Idempotency-Key is missing or malformed", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = {@ExampleObject(name = "idempotency-key-missing", value = "{\"detail\":\"This operation requires an Idempotency-Key header: one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is missing\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-missing\"}"), @ExampleObject(name = "idempotency-key-malformed", value = "{\"detail\":\"The Idempotency-Key header must be one String of 1 to 255 characters from A-Z, a-z, 0-9 and - . _ ~, with no parameters.\",\"status\":400,\"title\":\"Idempotency-Key is malformed\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-malformed\"}")}))
    @ApiResponse(responseCode = "404", description = "Customer not found", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "customer-not-found", value = "{\"detail\":\"no customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody/pauses\",\"status\":404,\"title\":\"Customer not found\",\"type\":\"tag:tiffinbox.example,2026:customer-not-found\",\"name\":\"Nobody\"}")))
    @ApiResponse(responseCode = "409", description = "A request is outstanding for this Idempotency-Key", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "idempotency-key-outstanding", value = "{\"detail\":\"A request with this Idempotency-Key is still being processed. Retry it later with the same key.\",\"status\":409,\"title\":\"A request is outstanding for this Idempotency-Key\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-outstanding\"}")))
    @ApiResponse(responseCode = "422", description = "Idempotency-Key is already used", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "idempotency-key-reused", value = "{\"detail\":\"This Idempotency-Key was first used with a different request. Use a new key for a new request.\",\"status\":422,\"title\":\"Idempotency-Key is already used\",\"type\":\"tag:tiffinbox.example,2026:idempotency-key-reused\"}")))
    @PostMapping("/api/v1/customers/{name}/pauses")
    ResponseEntity<Map<String, Object>> add(@PathVariable String name, @RequestParam int days) {
        if (days < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "days must be at least 1");
        }
        PauseEntity p = pauses.add(name, days).orElseThrow(() -> new CustomerNotFound(name));
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{id}").buildAndExpand(p.getId()).toUri();
        return ResponseEntity.created(location).body(pause(p.getId(), name, days));
    }

    // Course 9, unit 09: this route's own not-found problem (a ResponseStatusException: about:blank, no name member), documented with the answer it sent
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "404", description = "Not Found", content = @Content(mediaType = "application/problem+json",
            schema = @Schema(implementation = ProblemDetail.class), examples = @ExampleObject(name = "not-found", value = "{\"detail\":\"no pause 1 for a customer named Nobody\",\"instance\":\"/api/v1/customers/Nobody/pauses/1\",\"status\":404,\"title\":\"Not Found\"}")))
    @GetMapping("/api/v1/customers/{name}/pauses/{id}")
    Map<String, Object> one(@PathVariable String name, @PathVariable long id) {
        int days = pauses.days(name, id).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "no pause " + id + " for a customer named " + name));
        return pause(id, name, days);
    }

    private static Map<String, Object> pause(long id, String name, int days) {
        var out = new LinkedHashMap<String, Object>();
        out.put("id", id);
        out.put("customer", name);
        out.put("days", days);
        return out;
    }
}
