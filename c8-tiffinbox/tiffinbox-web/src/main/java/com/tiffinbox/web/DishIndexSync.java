package com.tiffinbox.web;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * Course 8, unit 22: the copy of each new dish row, written into the index after the row's transaction commits - a listener for
 * DishSaved in the phase AFTER_COMMIT, so a row the table rolls back is never copied. It saves through Dishes, the repository,
 * whose save sends the document with refresh=false and then a _refresh of the index: the count that follows the route reads the
 * new document (../c8-unit22, sync). The row is the source and the index a copy: the listener runs once the commit is done, and a
 * failure in it reaches no caller - the row stays, the index lacks the copy until a start rebuilds it (../c8-unit22, drift, where
 * the harness plants that failure). Under the profile "dev" only, as Dishes is.
 */
@Component
@Profile("dev")
public class DishIndexSync {

    private final Dishes dishes;

    DishIndexSync(Dishes dishes) {
        this.dishes = dishes;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    void copy(DishSaved saved) {
        dishes.save(new Dish(String.valueOf(saved.id()), saved.name(), saved.mealType(), saved.price()));
    }
}
