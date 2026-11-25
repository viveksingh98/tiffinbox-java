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
 *
 * <p>Course 8, unit 22: the route reads Dishes.searchByName since, and each hit carries the fragment Elasticsearch marked for it -
 * for veg, the fragment of Vegetarian Lunch Box with Vegetarian in em tags: the analyzer's synonym put veg there, and the fragment
 * shows which word of the name matched (../c8-unit22, highlight). The index is the copy the start rebuilds and the listener
 * DishIndexSync adds to after each POST /dishes commits (../c8-unit22, sync).
 */
@RestController
@Profile("dev")
public class DishSearch {

    /** One hit: the document's id (the row's), the dish's name, and the fragments of the name Elasticsearch marked. */
    public record Hit(String id, String name, List<String> fragment) {
    }

    private final Dishes dishes;

    DishSearch(Dishes dishes) {
        this.dishes = dishes;
    }

    /** 200 and the hits, in the order Elasticsearch returned them. */
    @GetMapping("/dishes/search")
    List<Hit> search(@RequestParam String q) {
        return dishes.searchByName(q).getSearchHits().stream()
                .map(h -> new Hit(h.getContent().id(), h.getContent().name(), h.getHighlightField("name"))).toList();
    }
}
