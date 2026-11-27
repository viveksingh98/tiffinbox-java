#!/bin/sh
# Course 9 unit 22's exercise, the start: sh break.sh TREE (a copy of ../after - never ../after itself). ONE file added, printed: a
# route that reads the request body onto the entity (Jackson's readerForUpdating on CustomerEntity, then saveAndFlush) - the shape of
# the receipts' "harness's entity-bound route". No shipped route reads a body onto an entity; this one exists only in your copy.
[ -n "$1" ] && [ -d "$1/tiffinbox-web" ] || { echo "usage: sh break.sh TREE (a copy of ../after)"; exit 2; }
T=$(cd "$1" && pwd); A=$(cd "$(dirname "$0")/../after" && pwd)
[ "$T" != "$A" ] || { echo "break.sh refuses ../after itself: copy it first"; exit 2; }
F="$T/tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerOverwrite.java"
[ ! -e "$F" ] || { echo "break.sh: $F already exists"; exit 1; }
cat > "$F" <<'JAVA'
package com.tiffinbox.web;

import com.tiffinbox.CustomerEntity;
import com.tiffinbox.CustomerEntityRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.json.JsonMapper;

/** Course 9 unit 22's exercise (never shipped): PUT /exercise/customers/{name} reads the body onto the entity the URL names. */
@RestController
final class CustomerOverwrite {

    private final CustomerEntityRepository customers;
    private final JsonMapper json;

    CustomerOverwrite(CustomerEntityRepository customers, JsonMapper json) {
        this.customers = customers;
        this.json = json;
    }

    @PutMapping("/exercise/customers/{name}")
    ResponseEntity<String> put(@PathVariable String name, @RequestBody String body) {
        CustomerEntity row = customers.findByName(name).orElse(null);
        if (row == null) return ResponseEntity.notFound().build();
        json.readerForUpdating(row).readValue(body);   // the body onto the entity: every member it has
        customers.saveAndFlush(row);
        return ResponseEntity.ok("saved");
    }
}
JAVA
echo "added tiffinbox-web/src/main/java/com/tiffinbox/web/CustomerOverwrite.java (PUT /exercise/customers/{name}: json.readerForUpdating(row).readValue(body), then saveAndFlush)"
