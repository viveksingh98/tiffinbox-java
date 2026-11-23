package com.tiffinbox.web;

import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Course 8, unit 21: GET /dishes/search?q=... - the dishes Elasticsearch's index finds for the words given, as JSON, each hit's id
 * and name. Elasticsearch answers it, never PostgreSQL: the index is the copy the "dev" start rebuilt from the dish rows. Under the
 * profile "dev" only - on the default run there is no index and no Dishes, and the route answers 404 (../c8-unit21, default).
 */
@RestController
@Profile("dev")
public class DishSearch {

    /** One hit: the document's id (the row's) and the dish's name. */
    public record Hit(String id, String name) {
    }

    private final Dishes dishes;

    DishSearch(Dishes dishes) {
        this.dishes = dishes;
    }

    /** 200 and the hits, in the order Elasticsearch returned them. */
    @GetMapping("/dishes/search")
    List<Hit> search(@RequestParam String q) {
        return dishes.findByName(q).stream().map(d -> new Hit(d.id(), d.name())).toList();
    }
}
