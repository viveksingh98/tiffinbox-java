package com.tiffinbox.web;

import org.springframework.context.annotation.Profile;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Course 8, unit 18 - the menu in MongoDB, under the profile "dev": MenuDay's documents in the collection menu, through Boot's
 * MongoTemplate. GET /menu/{day} reads one day by its id - day-1 to day-30 - and answers that document as JSON, its items inside it
 * (200), or 404 with no body for a day the menu does not hold (day-31). TiffinBoxServer.start() fills it: reset(), then fill() with
 * the thirty days.
 *
 * <p>Why the fill resets: insertAll adds, and the ids are the days - a second start against the same MongoDB would insert day-1 again
 * and the store refuses a second document with the same id. reset() removes every document of the collection first (a delete with
 * an empty query, never a drop: a drop would take the collection's indexes with it); two starts in a row leave thirty documents and
 * the same day-19 (../c8-unit18, twice).
 *
 * <p>Why the profile "dev": under the profile dev, Mongo is required - Compose starts it beside Postgres and Redis, and without it
 * the start stops: the fill names the driver's exception, and TiffinBox does not start (../c8-unit18, absent). The default run has
 * no Menus bean, no /menu (404) and builds no MongoClient: application.yaml excludes Boot's three MongoDB auto-configurations, and
 * application-dev.yaml clears that list (../c8-unit18, default).
 */
@RestController
@Profile("dev")
public class Menus {

    private final MongoTemplate mongo;

    Menus(MongoTemplate mongo) {
        this.mongo = mongo;
    }

    /** Every document of the collection menu removed - a delete with an empty query; the collection and its indexes stay. */
    public void reset() {
        mongo.remove(new Query(), MenuDay.class);
    }

    /** The days inserted in one command (insertAll). */
    public void fill(List<MenuDay> days) {
        mongo.insertAll(days);
    }

    /** One day's document by its id: 200 and the document, or 404 with no body. */
    @GetMapping("/menu/{day}")
    ResponseEntity<MenuDay> menu(@PathVariable String day) {
        MenuDay m = mongo.findById(day, MenuDay.class);
        return m == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(m);
    }
}
