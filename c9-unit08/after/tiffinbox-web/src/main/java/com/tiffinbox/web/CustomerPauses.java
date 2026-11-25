package com.tiffinbox.web;

import com.tiffinbox.PauseEntity;
import org.springframework.http.HttpStatus;
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

    @PostMapping("/api/v1/customers/{name}/pauses")
    ResponseEntity<Map<String, Object>> add(@PathVariable String name, @RequestParam int days) {
        if (days < 1) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "days must be at least 1");
        }
        PauseEntity p = pauses.add(name, days).orElseThrow(() -> new CustomerNotFound(name));
        URI location = ServletUriComponentsBuilder.fromCurrentRequestUri().path("/{id}").buildAndExpand(p.getId()).toUri();
        return ResponseEntity.created(location).body(pause(p.getId(), name, days));
    }

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
